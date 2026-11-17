{ pkgs, ... }: {
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;   # GUI version
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty vscodium
    zathura feh mpv
    inkscape dia veusz xournalpp
    qbittorrent guvcview gparted
    kdePackages.konversation
    texliveMedium   # smaller than texliveFull
    libreoffice-qt6-fresh
  ];
}
