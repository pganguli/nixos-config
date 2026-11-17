{ pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;   # sets EDITOR=nvim
    viAlias = true;         # "vi" opens nvim
    vimAlias = true;        # "vim" opens nvim
  };

  programs.java.enable = true;   # also sets JAVA_HOME

  # rust-analyzer needs the source of the Rust standard library
  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  environment.systemPackages = with pkgs; [
    # C and C++
    (lib.hiPrio gcc) clang   # gcc owns the "cc" command
    gnumake cmake gdb valgrind

    # Python
    (python3.withPackages (ps: with ps; [
      dbus-python   # "import dbus"
      pygobject3    # "from gi.repository import GLib" (main loop for D-Bus signals)
    ]))
    uv ruff ty pipx

    # Rust stable (Nix manages the version)
    rustc cargo rustfmt clippy rust-analyzer

    # Go
    go

    # Julia (Nix manages the version)
    julia-bin

    # Static site generator
    hugo

    # Claude Code CLI (the command is "claude"; Nix updates it, not its own updater)
    claude-code

    # Neovim: tree-sitter CLI (builds the parsers)
    tree-sitter

    # Language servers (the list in home/files/nvim/plugin/40_lsp.lua; rust-analyzer is above)
    clang-tools                    # clangd
    gopls
    basedpyright
    typescript-language-server
    lua-language-server
    bash-language-server
    vscode-langservers-extracted   # jsonls, html, cssls
    yaml-language-server
    taplo
    marksman
  ];
}
