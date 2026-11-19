{ pkgs, ... }: {
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;   # GUI version
  };

  # Zoom, with screen sharing through the Plasma portal
  programs.zoom-us.enable = true;

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    thunderbird   # email, and IRC chat
    feh
    inkscape dia veusz xournalpp
    qbittorrent guvcview gparted
    signal-desktop
    vesktop   # Discord client
    spotify
    texliveMedium   # smaller than texliveFull
    libreoffice-qt6-fresh
  ];
}
