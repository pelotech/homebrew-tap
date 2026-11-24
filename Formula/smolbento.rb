class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.39.0/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "f63b97f48ca1c133530acb637d8dc518d9e416f9e5ae8af8014df8591935dc31"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.39.0/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "843693a2bb6b4b5218f412086f29ead2504b5324761ffa544089ae2e8ca34247"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.39.0/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2a37ce2fe4e211df89286205f4cf03c70c0a515877d7102ed7c6326a3818d070"
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
