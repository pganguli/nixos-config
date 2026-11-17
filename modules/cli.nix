{ pkgs, ... }: {
  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    # Basics
    git vifm rsync rclone calc wget unzip
    wl-clipboard   # Wayland clipboard (Neovim needs it)

    # Search and files
    ripgrep fd fclones   # fzf comes from Home Manager

    # Media and documents
    ffmpeg-full imagemagick oxipng jpegoptim tesseract img2pdf
    poppler-utils   # pdfseparate, pdfunite, pdftotext, ...
    pandoc yt-dlp

    # Hardware, network and binaries
    pciutils nmap upx
  ];
}
