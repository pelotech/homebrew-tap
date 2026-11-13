class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.17.1/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "6867590bdc15e77259d126d8738f4d984a1ab80758366f97b9a955da844ba354"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.17.1/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "8220596695d1d0bc93b9a0c2efcf53bb9edc32732d7d22bb279ca023ba3f2e2c"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.17.1/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6d3acdf0286834b028bb815006a2c538270eeeca9f247eda2cb1d08329e5c675"
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
