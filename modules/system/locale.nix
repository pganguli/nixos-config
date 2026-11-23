{ pkgs, ... }: {
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # IBus with the Typing Booster engine (predictive typing, emoji, multilingual).
  # Add the engine in System Settings > Keyboard > Input Method, or "ibus-setup".
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    # Only the US English dictionary: fewer languages means faster, cleaner suggestions
    # libsoup is added because the preferences window imports Soup (GI) and
    # nixpkgs does not provide it, so the window crashed on start.
    ibus.engines = [
      (pkgs.ibus-engines.typing-booster.override {
        langs = [ "en-us" ];
        typing-booster = pkgs.ibus-engines.typing-booster-unwrapped.overrideAttrs (old: {
          buildInputs = old.buildInputs ++ [ pkgs.libsoup_3 ];
        });
      })
    ];
    # KDE Wayland talks text-input-v3 to KWin, so GTK_IM_MODULE and
    # QT_IM_MODULE are not set (only XMODIFIERS, for Xwayland apps).
    ibus.waylandFrontend = true;
  };
}
