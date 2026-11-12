class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.15.2/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "4bfbd917b3a0d94af63b7e66cbf7b343bd2e16a67d27c9ea67b6364578170a69"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on "smol-machines/tap/smolvm"

  on_macos do
    # There is no Intel macOS build.
    depends_on arch: :arm64
  end

  on_linux do
    on_arm do
      url "https://github.com/pelotech/smolbento/releases/download/v0.15.2/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "32091f7d49e7a8afcc5f1b4a9d988650b561da858942d582232274e83634eac6"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.15.2/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "ebb6fd00a53aa2ccd18497f644d59ae4f1432af45dba768908bdc5b666aee74c"
    end
  end

  def install
    bin.install "smolbento"
    # `sbx` is deliberately not linked: it would shadow Docker Sandboxes' own `sbx`.
    bin.install_symlink bin/"smolbento" => "sbt"
    bin.install_symlink bin/"smolbento" => "bento"
    # smolbento's clap command is named `sbt`, so its completions are for `sbt`.
    generate_completions_from_executable(bin/"smolbento", "completion", base_name: "sbt")
  end

  def caveats
    <<~EOS
      smolbento is linked as `smolbento`, `sbt` and `bento`. `sbx` is not linked, so it
      cannot clash with Docker Sandboxes. To also use it as `sbx`, add to your shell rc:
        alias sbx=sbt
    EOS
  end

  test do
    assert_match "smolbento version v#{version}", shell_output("#{bin}/smolbento version")
    assert_match version.to_s, shell_output("#{bin}/sbt --version")
  end
end
