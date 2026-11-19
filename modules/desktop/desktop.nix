{ pkgs, ... }: {
  # Plasma and login screen
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Remove default apps that I do not use
  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    okular
    gwenview
    kate
    ktexteditor
    khelpcenter
    krdp
    qrca
    plasma-keyboard
    konsole
  ];

  # ksystemstats' GPU plugin runs "nvidia-smi dmon" forever, which keeps the
  # NVIDIA GPU out of runtime suspend (~5-10 W). Remove the plugin; the
  # System Monitor then has no NVIDIA/GPU sensors.
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
        ksystemstats = kprev.ksystemstats.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            rm $out/lib/qt-6/plugins/ksystemstats/ksystemstats_plugin_gpu.so
          '';
        });
      });
    })
  ];

  # Font rendering (the settings from Plasma's Fonts page, which wrote
  # ~/.config/fontconfig/fonts.conf)
  fonts.fontconfig = {
    antialias = true;
    subpixel.rgba = "vbgr";
    hinting = { enable = true; style = "slight"; };
  };

  # Printing
  services.printing.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Browser
  programs.firefox = {
    enable = true;
    # Installed in the profile on first start. The user can disable them, and
    # their own settings stay in the profile (uBlock Origin filters, LeechBlock
    # blocks, ...), which are not declared here.
    policies.ExtensionSettings =
      let
        amo = slug: {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        };
      in {
        "uBlock0@raymondhill.net" = amo "ublock-origin";
        "sponsorBlocker@ajay.app" = amo "sponsorblock";
        "myallychou@gmail.com" = amo "youtube-recommended-videos";   # Unhook
        "leechblockng@proginosko.com" = amo "leechblock-ng";
        "@testpilot-containers" = amo "multi-account-containers";
        "{c607c8df-14a7-4f28-894f-29e8722976af}" = amo "temporary-containers";
      };
  };
}
