# pelotech Homebrew tap

```sh
brew trust pelotech/tap smol-machines/tap   # Homebrew 7+ only loads trusted third-party taps
brew tap smol-machines/tap                  # smolvm dependency; Homebrew 7+ won't auto-tap it
brew install pelotech/tap/smolbento
```

Trusting `pelotech/tap` also lets a plain `brew upgrade` update smolbento.

| Formula | Description | Platforms |
|---|---|---|
| [`smolbento`](https://github.com/pelotech/smolbento) | Docker Sandboxes (`sbx`) compatible agent sandboxes on smolvm microVMs. Installs `smolbento`, `sbt` and `bento` (not `sbx`) and pulls in `smol-machines/tap/smolvm`. | macOS arm64, Linux x86_64/arm64 |

## How updates work

Formulas install prebuilt, cosign-signed release tarballs. The [`bump`](.github/workflows/bump.yaml)
workflow updates a formula when:

- a project's release workflow sends a `repository_dispatch` (`event_type: bump-formula`,
  `client_payload: {formula, version}`), or
- the daily schedule finds a formula behind its project's latest GitHub release, or
- someone runs it by hand (Actions → bump → Run workflow).

[`scripts/bump-formula`](scripts/bump-formula) downloads every tarball and its `.sigstore.json`. It
checks that each was signed by `.github/workflows/release-please.yaml` on the project's `main`
branch, and only then writes the checksums. The workflow opens a PR as `pt-release-please` with
auto-merge on, and [`tests`](.github/workflows/tests.yaml) (style, audit, install and test on macOS
and Linux) must pass before it merges.

## Adding a formula

1. The project publishes `.tar.gz` release assets with a cosign `.sigstore.json` bundle each,
   signed from `.github/workflows/release-please.yaml` on `main`.
2. Copy [`Formula/smolbento.rb`](Formula/smolbento.rb). Keep `homepage` pointing at the GitHub repo
   and don't add a `version` line (Homebrew reads it from the urls). Write the same literal
   `/releases/download/vX.Y.Z/` in every `url`, and put each `sha256` on the line right after its
   `url`. Every OS/arch must resolve to a url: use a top-level `url`, override it in
   `on_linux`/`on_arm`/`on_intel`, and refuse unsupported platforms with `depends_on arch:`. Check
   with `brew readall --os=all --arch=all pelotech/tap`.
3. In the project's release workflow, after the assets are uploaded, mint a `pt-release-please`
   token for `pelotech/homebrew-tap` and run:
   ```sh
   gh api repos/pelotech/homebrew-tap/dispatches -f event_type=bump-formula \
     -f "client_payload[formula]=<name>" -f "client_payload[version]=<X.Y.Z>"
   ```
   Until this is in place, the daily schedule picks up new releases.

## Local checks

With [Nix](https://nixos.org) and [direnv](https://direnv.net), `direnv allow` gives you the tools.

```sh
prek install --hook-type pre-commit --hook-type commit-msg
prek run --all-files                 # yamllint, actionlint, zizmor, shellcheck, shfmt, commitlint
scripts/test-bump-formula            # needs network
brew tap pelotech/tap "$PWD" && brew trust pelotech/tap smol-machines/tap
brew readall --os=all --arch=all pelotech/tap && brew style Formula/ && brew audit --strict --online --tap pelotech/tap
```
