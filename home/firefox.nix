# Firefox profile. The package and the policies (extensions) come from the
# NixOS module in modules/desktop/desktop.nix; this only manages the profile.
{ ... }: {
  programs.firefox = {
    enable = true;
    package = null;   # installed system-wide by programs.firefox in desktop.nix
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
      };
    };
  };
}
