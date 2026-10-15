class Sbrs < Formula
  desc "SeleniumBase for Rust: browser automation and testing CLI, plus an MCP server"
  homepage "https://github.com/MustCodeAl/seleniumbase-rs"
  url "https://github.com/MustCodeAl/seleniumbase-rs/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "18accd0b7d300d687fd3b79c4465a440a02523d3473a2971946700ba46e4890d"
  license "MIT"
  head "https://github.com/MustCodeAl/seleniumbase-rs.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args, "--features", "mcp-server"

    # Shell completions; Warp uses them through its native shell completions.
    generate_completions_from_executable(bin/"sbrs", "completions", shells: [:bash, :zsh, :fish, :pwsh])

    # The Fig spec (Warp's built-in specs, inshellisense, Amazon Q), the usage spec
    # (jdx/usage, mise) and Warp Workflows.
    (pkgshare/"fig").mkpath
    (pkgshare/"fig/sbrs.ts").write Utils.safe_popen_read(bin/"sbrs", "completions", "fig")
    (pkgshare/"warp-workflows").install Dir[".warp/workflows/*.yaml"]
    (pkgshare/"usage").mkpath
    (pkgshare/"usage/sbrs.usage.kdl").write Utils.safe_popen_read(bin/"sbrs", "completions", "usage")
  end

  def caveats
    <<~EOS
      Completions for bash, zsh and fish are installed. Warp uses them too
      (Settings > Features > "native shell completions", on by default).

      Warp Workflows for sbrs are in:
        #{opt_pkgshare}/warp-workflows
      Copy them to ~/.warp/workflows to see them in Warp's command palette:
        mkdir -p ~/.warp/workflows && cp #{opt_pkgshare}/warp-workflows/*.yaml ~/.warp/workflows/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sbrs --version")
    assert_match "mkfile", shell_output("#{bin}/sbrs completions zsh")
    assert_match "Fig.Spec", shell_output("#{bin}/sbrs completions fig")
  end
end
