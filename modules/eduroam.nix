# SecureW2 JoinNow (eduroam / UNC enrollment script) needs an FHS layout:
# it looks for openssl, xdg-open, wpa_supplicant and python only in
# /bin, /usr/bin and /usr/sbin, which NixOS does not have.
# "securew2-env" gives it those paths. Usage (as your user, not root):
#   securew2-env ~/Downloads/SecureW2_JoinNow.run
{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.buildFHSEnv {
      name = "securew2-env";
      targetPkgs = p: with p; [
        (python3.withPackages (ps: [ ps.dbus-python ]))   # NetworkManager over D-Bus
        openssl          # key and certificate request
        xdg-utils        # xdg-open: opens the UNC sign-in page in the browser
        wpa_supplicant   # version check: >= 2.1 turns on server name validation
        which coreutils gnutar gzip gnused   # used by the .run wrapper
      ];
      runScript = "bash";
    })
  ];
}
