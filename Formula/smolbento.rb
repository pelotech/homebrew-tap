class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.2.1/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "0a1564a38b78179c8be2b2c358ed2a6b1d5a52394da83281efe8795c394704ff"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.2.1/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "b7216e3dfa3bd0c58a38ab70735ba8fe65621de5ce8714706146383465befe79"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.2.1/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "97c65e9c86ac837e3866a6582a0a15fcb2034065ecbc8797712421e06959806b"
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
