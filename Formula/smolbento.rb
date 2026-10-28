class Smolbento < Formula
  desc "Docker Sandboxes (sbx) compatible agent sandboxes on smolvm microVMs"
  homepage "https://github.com/pelotech/smolbento"
  # Prebuilt release tarballs (cosign signatures are verified when the formula is bumped);
  # Homebrew reads the version from these urls.
  url "https://github.com/pelotech/smolbento/releases/download/v0.8.0/smolbento-aarch64-apple-darwin.tar.gz"
  sha256 "d49bdf613b91446dac101189f2704dfc71c4694c27fe7d8fc32f35e8c9c04978"
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
      url "https://github.com/pelotech/smolbento/releases/download/v0.8.0/smolbento-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "dc9ae094aae0a0a767ccbca028ed91963eae0e69b9d28764b4048a6efb2b36db"
    end
    on_intel do
      url "https://github.com/pelotech/smolbento/releases/download/v0.8.0/smolbento-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "75fc71797162c3b28f85520ccbacf4ad5eafda6fdfa8db44d77bf9c270f768e2"
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
