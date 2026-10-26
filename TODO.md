# homebrew-tap TODO

Open follow-ups for this tap. Tick items off (or delete them) in the PR that resolves them.

## Blocked on upstream (smol-machines/homebrew-tap)

- [ ] **smolvm can't be installed on Linux.** `Formula/smolvm.rb` runs patchelf on
  `libexec/lib/libkrun.so.1`, but the 1.32.3 tarball ships `lib/libkrun.so.2` (upstream bump
  `c04155c`, 2026-10-26). Linux users can't `brew install pelotech/tap/smolbento` until it's fixed.
  - When fixed: in `.github/workflows/tests.yaml`, remove the `INSTALL_FLAGS` env and the
    `$INSTALL_FLAGS` in the `install` job (look for the TODO comment).
- [ ] **smolvm has no Intel-macOS url.** Homebrew 7 rejects the tap when it's tapped while trusted,
  so the README and CI must run `brew tap smol-machines/tap` before `brew trust`.
  - When fixed: the tap/trust order no longer matters. Optionally simplify the comment in
    `tests.yaml` (`lint` job).
  - The accepted fix is the homebrew-core pattern our formula already uses: a top-level `url`,
    `on_linux` overrides, and `on_macos do depends_on arch: :arm64 end` (as in core's `podman`,
    `pomerium` and `reg`).

## pelotech/smolbento (separate PR)

- [ ] Release job (`needs: [release-please, binaries]`) mints a `pt-release-please` token for
  `pelotech/homebrew-tap` and sends the `bump-formula` dispatch
- [ ] Install docs: add the Homebrew instructions (tap smol-machines, trust, install)

## Nice to have (deferred review items)

- [ ] `scripts/test-bump-formula`: check stderr so the wrong-signer and missing-release cases prove
  their cause
- [ ] `scripts/bump-formula`: usage message; reject downgrades (newer-version-only)
- [ ] `scripts/outdated-formulae`: warn and continue per formula (do this before adding a 2nd
  formula)
- [ ] `bump.yaml`: `git push --force-with-lease`; rename the `app-id` input to `client-id`
- [ ] Optionally scope the App secret to a `main`-only environment
