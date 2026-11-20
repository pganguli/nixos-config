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

  # Email, and IRC chat. Add-ons are installed in the profile on first start;
  # the user can disable them, and their settings stay in the profile.
  programs.thunderbird = {
    enable = true;
    policies.ExtensionSettings =
      let
        atn = slug: {
          installation_mode = "normal_installed";
          install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/${slug}/latest.xpi";
        };
      in {
        "gconversation@xulforum.org" = atn "gmail-conversation-view";                    # Thunderbird Conversations
        "ImportExportToolsNG@cleidigh.kokkini.net" = atn "importexporttools-ng";
      };
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    feh
    inkscape dia veusz xournalpp
    qbittorrent guvcview gparted
    signal-desktop
    vesktop   # Discord client
    spotify
    texliveMedium   # smaller than texliveFull
    texlab          # LaTeX language server
    libreoffice-qt6-fresh
    # Chromium (not Google Chrome, not ungoogled). Native Wayland when available.
    (chromium.override { commandLineArgs = [ "--ozone-platform-hint=auto" ]; })
    zotero   # reference manager
  ];
}
