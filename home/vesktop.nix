# Vesktop (Discord client). Vesktop rewrites settings.json itself (window
# state, splash colors), so a read-only link would break it. Instead, merge
# the keys listed here into the existing file on every switch and leave the
# rest alone. The Vencord settings (settings/settings.json) and quickCss.css
# are still the defaults, so they are not declared.
{ lib, pkgs, ... }:
let
  declared = pkgs.writeText "vesktop-settings.json" (builtins.toJSON {
    arRPC = true;                       # Discord rich presence for local games/apps
    hardwareVideoAcceleration = true;
    tray = false;
    minimizeToTray = false;
    enableMenu = false;
    enableSplashScreen = false;
    splashTheming = false;
    enableTaskbarFlashing = true;
  });
in {
  home.activation.vesktopSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="$HOME/.config/vesktop/settings.json"
    run mkdir -p "$(dirname "$f")"
    if [ -f "$f" ]; then
      tmp="$(mktemp)"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$f" ${declared} > "$tmp" \
        && run install -m 644 "$tmp" "$f"
      rm -f "$tmp"
    else
      run install -m 644 ${declared} "$f"
    fi
  '';
}
