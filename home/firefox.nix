# Firefox: the package, its extensions (policies) and the profile.
{ pkgs, config, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    # Lets PassFF talk to "pass". nixpkgs hard-codes plain pass (no
    # extensions) into the host, so OTP failed; give it the pass with
    # pass-otp from programs.password-store (home/pganguli.nix).
    nativeMessagingHosts = [
      (pkgs.passff-host.override { pass = config.programs.password-store.package; })
    ];

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
        "passff@invicem.pro" = amo "passff";                        # password-store (pass)
        "@testpilot-containers" = amo "multi-account-containers";
        "{c607c8df-14a7-4f28-894f-29e8722976af}" = amo "temporary-containers";
      };

    profiles.default = {
      id = 0;
      name = "default";
      path = "3vzc4ryy.default";   # the existing profile directory
      isDefault = true;

      # Betterfox v154 (https://github.com/yokoffing/Betterfox), unmodified.
      # Put overrides in "settings" below, not in this file, so a newer
      # Betterfox version can be dropped in as it is.
      extraConfig = builtins.readFile ./files/firefox/user.js;

      # Preferences changed on purpose, on top of Betterfox
      settings = {
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.tabs.loadInBackground" = false;           # links in new tabs open in front
        "browser.link.force_default_user_context_id_for_external_opens" = true;
        "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.uidensity" = 1;                           # compact
        "browser.warnOnQuitShortcut" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;

        # No back/forward on a two-finger touchpad swipe
        "browser.gesture.swipe.left" = "";
        "browser.gesture.swipe.right" = "";
        "widget.disable-swipe-tracker" = true;

        # No password, address or card saving, and no breach alerts
        "signon.rememberSignons" = false;
        "signon.firefoxRelay.feature" = "disabled";
        "signon.management.page.breach-alerts.enabled" = false;
        "browser.urlbar.trustPanel.breachAlerts" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Google Safe Browsing page checks off (Betterfox only turns off the
        # remote download check)
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;

        # No captive-portal or connectivity checks (requests to
        # detectportal.firefox.com on startup and on network changes)
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
      };
    };
  };
}
