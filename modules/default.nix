# Every shared module. A host (hosts/<name>/) imports this, then adds its own hardware facts.
{ ... }: {
  imports = [
    # Base system
    ./system/nix.nix
    ./system/users.nix
    ./system/locale.nix
    ./system/security.nix
    ./system/tailscale.nix
    ./system/dns.nix
    ./system/eduroam.nix   # iwd + eduroam: the eduroam-iwd command
    ./system/tetherfusenet.nix   # phone tethering: tun2proxy to TetherFuseNet's SOCKS5
    ./system/storage.nix
    ./system/swap.nix
    ./system/power.nix
    ./system/home.nix      # Home Manager (the user config is in ../home)

    # Desktop
    ./desktop/desktop.nix
    ./desktop/gui.nix

    # Terminal
    ./terminal/shell.nix
    ./terminal/cli.nix

    # Development
    ./dev/languages.nix    # compilers, language servers, CUDA, Arduino, Nordic
    ./dev/matlab.nix
    ./dev/msp430.nix
    ./dev/lab-instruments.nix
  ];
}
