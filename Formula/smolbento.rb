class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.22.0/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "3e9a486e1b44a71523e5882d228fae6b00ba6f878f7f3b8fbb96e05268756e5a"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.22.0/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0ae7fada9b31466742f6a25f93363035e50bd780c461bd20e36654024aac753a"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.22.0/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c0d8170c405fb506bf232b1e40227aee4a6d7924e20f263a3e2afee4892a8607"
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
