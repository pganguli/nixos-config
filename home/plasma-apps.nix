# Dolphin, file dialogs, KIO and other KDE apps: the settings made by hand in
# the old Plasma setup, now written by plasma-manager.
{ lib, pkgs, ... }:
let
  # File types that open in their own application and not inside Dolphin
  # (File Associations > Embedding: "Show in separate viewer")
  noEmbed = [
    "application/json"
    "application/pdf"
    "application/x-docbook+xml"
    "application/x-matroska"
    "application/x-yaml"
    "audio/aac"
    "audio/mp4"
    "audio/mpeg"
    "audio/mpegurl"
    "audio/ogg"
    "audio/vnd.rn-realaudio"
    "audio/vorbis"
    "audio/x-flac"
    "audio/x-mp3"
    "audio/x-mpegurl"
    "audio/x-ms-wma"
    "audio/x-musepack"
    "audio/x-oggflac"
    "audio/x-pn-realaudio"
    "audio/x-scpls"
    "audio/x-speex"
    "audio/x-vorbis"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
    "image/avif"
    "image/bmp"
    "image/heif"
    "image/jpeg"
    "image/png"
    "image/webp"
    "image/x-icns"
    "text/markdown"
    "text/plain"
    "text/x-cmake"
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/avi"
    "video/divx"
    "video/dv"
    "video/fli"
    "video/flv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.divx"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-avi"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg2"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-msvideo"
    "video/x-ogm"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"
    "x-scheme-handler/geo"
  ];
in {
  programs.plasma.configFile = {
    filetypesrc.EmbedSettings = lib.listToAttrs
      (map (t: lib.nameValuePair "embed-${t}" false) noEmbed);

    dolphinrc = {
      MainWindow.MenuBar = "Disabled";
      "KFileDialog Settings" = {
        "Places Icons Auto-resize" = false;
        "Places Icons Static Size" = 22;
      };
      PreviewSettings.Plugins = lib.concatStringsSep "," [
        "appimagethumbnail" "com.github.xournalpp.xournalpp" "audiothumbnail"
        "blenderthumbnail" "comicbookthumbnail" "cursorthumbnail" "org.gnome.Dia"
        "djvuthumbnail" "ebookthumbnail" "exrthumbnail" "directorythumbnail"
        "fontthumbnail" "imagethumbnail" "jpegthumbnail" "kraorathumbnail"
        "windowsexethumbnail" "windowsimagethumbnail" "mobithumbnail"
        "opendocumentthumbnail" "gsthumbnail" "rawthumbnail" "svgthumbnail"
        "ffmpegthumbs"
      ];
    };

    kiorc = {
      Confirmations = {
        ConfirmDelete = true;
        ConfirmEmptyTrash = true;
        ConfirmTrash = false;
      };
      "Executable scripts".behaviourOnLaunch = "alwaysAsk";
    };

    arkrc = {
      General = { LockSidebar = true; ShowSidebar = true; };
      MainWindow.StatusBar = "Disabled";
    };

    kaccessrc.Bell = { SystemBell = false; VisibleBell = true; };

    kwalletrc.Wallet."First Use" = false;

    discoverrc.Software.UseOfflineUpdates = true;

    # "Right-click > Compress / Extract / ..." entries
    kservicemenurc.Show = {
      compressfileitemaction = true;
      extractfileitemaction = true;
      forgetfileitemaction = true;
      hidefileitemaction = false;
      installFont = true;
      kactivitymanagerd_fileitem_linking_plugin = true;
      kio-admin = true;
      makefileactions = true;
      mountisoaction = true;
      movetonewfolderitemaction = true;
      setfoldericonitemaction = true;
      tagsfileitemaction = true;
      wallpaperfileitemaction = true;
    };
  };

  # The trash settings live in a group named after a path, which plasma-manager
  # cannot write (it reads "/" as a nested group). Days = 14, at most 10 % of the disk.
  home.activation.plasmaTrash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    k() { run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file ktrashrc \
      --group "$HOME/.local/share/Trash" "$@"; }
    k --key Days 14
    k --key LimitReachedAction 1
    k --key Percent 10
    k --key UseSizeLimit true
    k --key UseTimeLimit true
  '';
}
