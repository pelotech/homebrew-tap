class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.42.1/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "75e5a4cbfdd8c2360f843b040bb2e303e71c16d38b497192afcb1266e367963f"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.42.1/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "54068524a44ac8ff3e947ae11c40c340e56b1d63cde9b986e288167c3c61428a"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.42.1/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "fcc6f8a841df19e6692a09d5d11a29548854a7ac7dd27065caef2a22000105ea"
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
