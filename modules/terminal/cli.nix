{ pkgs, ... }: {
  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    # Basics
    rsync rclone calc wget
    openssl xdg-utils
    wl-clipboard   # Wayland clipboard (Neovim needs it)

    # Archives
    zip unzip _7zz   # _7zz is 7-Zip (7z, rar, and more)

    # Search and files
    ripgrep fd fclones   # fzf comes from Home Manager

    # Media and documents
    ffmpeg-full imagemagick oxipng jpegoptim tesseract img2pdf
    poppler-utils   # pdfseparate, pdfunite, pdftotext, ...
    pandoc yt-dlp

    # Passwords (gpg-agent and pinentry are set up in modules/system/security.nix)
    pass

    # Hardware, network and binaries
    pciutils nmap upx
    wpa_supplicant   # wpa_cli, wpa_passphrase; NetworkManager has its own copy
    ntfs3g   # NTFS tools: ntfsfix, ntfslabel, mkfs.ntfs, ...
    tbtools  # Thunderbolt/USB4 debugging tools: tblist, tbauth, tbadapters, ...
    e2fsprogs   # chattr, lsattr (file flags such as immutable)
  ];
}
