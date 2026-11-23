{ pkgs, ... }: {
  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    # Basics
    rsync rclone calc wget
    openssl xdg-utils
    wl-clipboard   # Wayland clipboard (Neovim needs it)

    # Archives
    zip unzip _7zz   # _7zz is 7-Zip (7z, rar, and more)
    mount-zip archivemount   # vifm mounts zips and tarballs with these

    # Search and files
    ripgrep fd fclones   # fzf comes from Home Manager

    # Media and documents
    ffmpeg-full imagemagick oxipng jpegoptim tesseract img2pdf
    poppler-utils   # pdfseparate, pdfunite, pdftotext, ...
    pandoc yt-dlp

    # Hardware, network and binaries
    pciutils nmap upx
    iwd   # iwctl, iwmon; NetworkManager drives the iwd daemon
    wpa_supplicant   # only so the eduroam enrollment script finds it (see system/nix.nix); iwd does the Wi-Fi
    ntfs3g   # NTFS tools: ntfsfix, ntfslabel, mkfs.ntfs, ...
    tbtools  # Thunderbolt/USB4 debugging tools: tblist, tbauth, tbadapters, ...
    e2fsprogs   # chattr, lsattr (file flags such as immutable)
  ];
}
