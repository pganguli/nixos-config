{ pkgs, lib, ... }:
let
  cudaRoot = pkgs.symlinkJoin {
    name = "cuda-nvcc-cudart";
    paths = with pkgs.cudaPackages; [
      cuda_nvcc
      (lib.getDev cuda_cudart)
      (lib.getLib cuda_cudart)
      (lib.getStatic cuda_cudart)
    ];
  };
in {
  programs.java.enable = true;   # also sets JAVA_HOME

  # rust-analyzer needs the source of the Rust standard library
  environment.variables.RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

  # Build systems (CMake, PyTorch, etc.) look for the toolkit here
  environment.variables.CUDA_PATH = "${cudaRoot}";

  environment.systemPackages = with pkgs; [
    # C and C++
    (lib.hiPrio gcc) clang   # gcc owns the "cc" command
    gnumake cmake gdb valgrind

    # CUDA: nvcc, cudart and headers only (the full cudatoolkit is several GB).
    # Prebuilt PyTorch wheels bring their own CUDA libraries. For a build that
    # needs more (cublas, cudnn...), add just that cudaPackages.* package.
    # The driver (libcuda) comes from hardware.nvidia in hosts/lenowo/laptop.nix.
    cudaRoot

    # Python
    (python3.withPackages (ps: with ps; [
      dbus-python   # "import dbus"
      pygobject3    # "from gi.repository import GLib" (main loop for D-Bus signals)
    ]))
    uv ruff ty pipx

    # Rust stable (Nix manages the version)
    rustc cargo rustfmt clippy rust-analyzer

    # Embedded: Nordic nrfutil and Zephyr's west
    nrfutil python3Packages.west

    # Arduino
    arduino-cli arduino-language-server

    # Go
    go

    # Julia (Nix manages the version)
    julia-bin

    # Static site generator
    hugo

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
    nil                            # Nix (Zed's Nix extension uses it)
    nixd                           # Nix (also supported by Zed's Nix extension)
  ];
}
