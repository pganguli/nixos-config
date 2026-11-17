{ pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;   # sets EDITOR=nvim
    viAlias = true;         # "vi" opens nvim
    vimAlias = true;        # "vim" opens nvim
  };

  programs.java.enable = true;   # also sets JAVA_HOME

  environment.systemPackages = with pkgs; [
    # C and C++
    (lib.hiPrio gcc) clang   # gcc owns the "cc" command
    gnumake cmake gdb valgrind

    # Python
    python3 uv ruff ty pipx

    # Rust (toolchains and rust-analyzer come from rustup)
    rustup

    # Go
    go

    # Julia (Nix manages the version)
    julia-bin

    # Neovim: tree-sitter CLI (builds the parsers)
    tree-sitter

    # Language servers (the list in home/files/nvim/plugin/40_lsp.lua)
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
