class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.41.4/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "088ea52fd9f9cb3d71756427252733413cd89cf40814747290984de8dca1ba29"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # smolbento downloads the smolvm release it's tested with on first use (into ~/.smolbento).
  on_macos do
    # There is no Intel macOS build.
    depends_on arch: :arm64
    # smolvm formats sandbox disks larger than 20 GiB with it.
    depends_on "e2fsprogs"
  end

  on_linux do
    on_arm do
      url "https://github.com/pelotech/smolbento/releases/download/v0.41.4/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c88b941b25d0372186b06067f4dfc97030d51bf5a4bc1cebeaa2035b68dbd09b"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.41.4/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f1acc4213652eba2397a4ac905c624c628c1472272cdec618da5a727cdcdcc84"
    end
  end

  def install
    bin.install "smolbento"
    # `sbx` and `sbt` are deliberately not linked: they would shadow Docker Sandboxes' `sbx` and
    # Scala's `sbt`.
    bin.install_symlink bin/"smolbento" => "bento"
    # smolbento's clap command is named `bento`, so its completions are for `bento`.
    generate_completions_from_executable(bin/"smolbento", "completion", base_name: "bento")
  end

  def caveats
    <<~EOS
      smolbento is linked as `smolbento` and `bento`. `sbx` and `sbt` are not linked, so they
      cannot clash with Docker Sandboxes or Scala's sbt. To use those names, add to your shell rc:
        alias sbx=bento sbt=bento

      smolbento downloads smolvm on first use into ~/.smolbento, with its sandboxes.
      To remove them too, run this before `brew uninstall smolbento`:
        bento reset --force
    EOS
  end

  test do
    assert_match "smolbento version v#{version}", shell_output("#{bin}/smolbento version")
    assert_match version.to_s, shell_output("#{bin}/bento --version")
  end
end
