{ pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets EDITOR=nvim
    viAlias = true;       # "vi" opens nvim
    vimAlias = true;       # "vim" opens nvim
  };

  programs.java.enable = true;   # also sets JAVA_HOME

  environment.systemPackages = with pkgs; [
    # C and C++
    (lib.hiPrio gcc) clang   # gcc owns the "cc" command
    gnumake cmake gdb valgrind

    # Python
    python3 uv ruff ty pipx

    # Rust (toolchains come from rustup)
    rustup

    # Julia (Nix manages the version)
    julia-bin
  ];
}
