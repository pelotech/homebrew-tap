class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.32.0/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "fc7e9326e6861609efe9dde475dc7f17a4f2693c1ea687ab7a4c747631a32ae8"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.32.0/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "2e0f855de469bdf57c9d8f90ff6a03747a9fb1a3e491d88a772f9078fca9d7f3"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.32.0/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e98d4cdfb716e90448fde84b3df746392f1698c6b57f9a5069e748cb62d77693"
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
