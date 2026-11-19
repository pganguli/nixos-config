# Default applications (from ~/.config/mimeapps.list, which Plasma's File
# Associations settings write)
{ ... }: {
  # MATLAB rewrites ~/.local/share/applications/mimeapps.list (the old
  # location) on its own, which replaces the link. Overwrite it on every
  # switch and do not back it up, or Home Manager fails on the old .bak.
  xdg.dataFile."applications/mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # MATLAB's links (its .desktop files are in ~/.local/share/applications)
      "x-scheme-handler/mw-matlab" = [ "mw-matlab.desktop" ];
      "x-scheme-handler/mw-matlabconnector" = [ "mw-matlabconnector.desktop" ];
      "x-scheme-handler/mw-simulink" = [ "mw-simulink.desktop" ];

      # Web: Firefox is the default browser (links from other programs open there)
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];

      "application/json" = [ "nvim.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "application/x-docbook+xml" = [ "nvim.desktop" ];
      "application/x-matroska" = [ "umpv.desktop" ];
      "application/x-yaml" = [ "nvim.desktop" ];
      "audio/aac" = [ "umpv.desktop" ];
      "audio/mp4" = [ "umpv.desktop" ];
      "audio/mpeg" = [ "umpv.desktop" ];
      "audio/mpegurl" = [ "umpv.desktop" ];
      "audio/ogg" = [ "umpv.desktop" ];
      "audio/vnd.rn-realaudio" = [ "umpv.desktop" ];
      "audio/vorbis" = [ "umpv.desktop" ];
      "audio/x-flac" = [ "umpv.desktop" ];
      "audio/x-mp3" = [ "umpv.desktop" ];
      "audio/x-mpegurl" = [ "umpv.desktop" ];
      "audio/x-ms-wma" = [ "umpv.desktop" ];
      "audio/x-musepack" = [ "umpv.desktop" ];
      "audio/x-oggflac" = [ "umpv.desktop" ];
      "audio/x-pn-realaudio" = [ "umpv.desktop" ];
      "audio/x-scpls" = [ "umpv.desktop" ];
      "audio/x-speex" = [ "umpv.desktop" ];
      "audio/x-vorbis" = [ "umpv.desktop" ];
      "audio/x-vorbis+ogg" = [ "umpv.desktop" ];
      "audio/x-wav" = [ "umpv.desktop" ];
      "image/avif" = [ "feh.desktop" ];
      "image/bmp" = [ "feh.desktop" ];
      "image/heif" = [ "feh.desktop" ];
      "image/jpeg" = [ "feh.desktop" ];
      "image/png" = [ "feh.desktop" ];
      "image/webp" = [ "feh.desktop" ];
      "image/x-icns" = [ "feh.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "text/plain" = [ "nvim.desktop" ];
      "text/x-cmake" = [ "nvim.desktop" ];
      "video/3gp" = [ "umpv.desktop" ];
      "video/3gpp" = [ "umpv.desktop" ];
      "video/3gpp2" = [ "umpv.desktop" ];
      "video/avi" = [ "umpv.desktop" ];
      "video/divx" = [ "umpv.desktop" ];
      "video/dv" = [ "umpv.desktop" ];
      "video/fli" = [ "umpv.desktop" ];
      "video/flv" = [ "umpv.desktop" ];
      "video/mp2t" = [ "umpv.desktop" ];
      "video/mp4" = [ "umpv.desktop" ];
      "video/mp4v-es" = [ "umpv.desktop" ];
      "video/mpeg" = [ "umpv.desktop" ];
      "video/msvideo" = [ "umpv.desktop" ];
      "video/ogg" = [ "umpv.desktop" ];
      "video/quicktime" = [ "umpv.desktop" ];
      "video/vnd.divx" = [ "umpv.desktop" ];
      "video/vnd.mpegurl" = [ "umpv.desktop" ];
      "video/vnd.rn-realvideo" = [ "umpv.desktop" ];
      "video/webm" = [ "umpv.desktop" ];
      "video/x-avi" = [ "umpv.desktop" ];
      "video/x-flv" = [ "umpv.desktop" ];
      "video/x-m4v" = [ "umpv.desktop" ];
      "video/x-matroska" = [ "umpv.desktop" ];
      "video/x-mpeg2" = [ "umpv.desktop" ];
      "video/x-ms-asf" = [ "umpv.desktop" ];
      "video/x-ms-wmv" = [ "umpv.desktop" ];
      "video/x-ms-wmx" = [ "umpv.desktop" ];
      "video/x-msvideo" = [ "umpv.desktop" ];
      "video/x-ogm" = [ "umpv.desktop" ];
      "video/x-ogm+ogg" = [ "umpv.desktop" ];
      "video/x-theora" = [ "umpv.desktop" ];
      "video/x-theora+ogg" = [ "umpv.desktop" ];
    };
  };
}
