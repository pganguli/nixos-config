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

  # Debug probes (ST-Link, CMSIS-DAP, J-Link...) for the logged-in user, without root
  services.udev.packages = [ pkgs.openocd pkgs.segger-jlink ];

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

    # Debug probes: OpenOCD, and SEGGER J-Link (JLinkExe, JLinkGDBServer, ...;
    # the license is accepted in modules/system/nix.nix)
    openocd segger-jlink

    # Serial console (/dev/ttyUSB*, /dev/ttyACM*; you are in the "dialout" group)
    picocom

    # Android: adb and fastboot (the package ships the udev rules for device access)
    android-tools
    scrcpy   # mirror and control an Android phone over adb

    # Arduino
    arduino-cli arduino-language-server

    # Go
    go

    # Julia (Nix manages the version)
    julia-bin

    # UPPAAL: modeling and verification of real-time systems (timed automata).
    # 5.1.0-beta6: nixpkgs only has 5.0.0 (2023). Drop the override once nixpkgs catches up.
    (uppaal.overrideAttrs (old: {
      version = "5.1.0-beta6";
      src = fetchzip {
        url = "https://download.uppaal.org/uppaal-5.1/uppaal-5.1.0/uppaal-5.1.0-beta6-linux64.zip";
        hash = "sha256-v+ENLv6WniH2rY09y27XzneThjMYJ9gck2Kwa+M0j9A=";
      };
    }))

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
