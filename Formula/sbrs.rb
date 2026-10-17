class Sbrs < Formula
  desc "SeleniumBase for Rust: browser automation and testing CLI, plus an MCP server"
  homepage "https://github.com/MustCodeAl/seleniumbase-rs"
  url "https://github.com/MustCodeAl/seleniumbase-rs/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "fa9ea22a37870752b45ecad203dec99bd5b5cacb5b5ac82a2013afadd0139731"
  license "MIT"
  head "https://github.com/MustCodeAl/seleniumbase-rs.git", branch: "main"

  depends_on "rust" => :build

  def install
    # The binaries are the workspace crate crates/cli; its default features are
    # pdf, mcp-server and plugins-builtin (the built-in plugins).
    system "cargo", "install", *std_cargo_args(path: "crates/cli")

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
    assert_match "mkfile", shell_output("#{bin}/sbrs completions usage")
    assert_match "shield", shell_output("#{bin}/sbrs plugin list")
    assert_match "Fig.Spec", shell_output("#{bin}/sbrs completions fig")
  end
end
