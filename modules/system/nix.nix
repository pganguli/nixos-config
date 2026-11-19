{ ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    auto-optimise-store = true;
  };

  # nh: "nh os switch" rebuilds this flake (no flags needed), with a build tree and a diff.
  # It also does the weekly garbage collection (it replaces nix.gc).
  programs.nh = {
    enable = true;
    flake = "/home/pganguli/.config/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.segger-jlink.acceptLicense = true;   # needed by nrfutil (accepts SEGGER's license terms)

  # Lets downloaded binaries run (uv Python, Zed extensions and language servers)
  programs.nix-ld.enable = true;

  # Lets scripts find programs at fixed paths such as /usr/bin/openssl or /bin/bash.
  # /usr/bin and /bin show the programs in the PATH of the program that looks.
  #
  # Needed by the UNC eduroam enrollment script (SecureW2 JoinNow .run file):
  # it looks for python (with dbus), openssl, xdg-open and wpa_supplicant only
  # in /bin, /usr/bin and /usr/sbin. Run it as your user: sh SecureW2_JoinNow.run
  #
  # After enrollment, eduroam fails with "no secrets were provided": NixOS runs
  # wpa_supplicant in a sandbox (user wpa_supplicant, no /home), so it can't
  # read the key the script puts in ~/.joinnow. Copy it to /etc and repoint:
  #   set conn "eduroam"   # nmcli -f NAME,TYPE connection show
  #   set key (nmcli -g 802-1x.private-key connection show "$conn")   # the .p12
  #   set pw  (sudo nmcli -s -g 802-1x.private-key-password connection show "$conn")
  #   sudo install -d -m 750 -o root -g wpa_supplicant /etc/eduroam
  #   sudo install -m 640 -o root -g wpa_supplicant $key /etc/eduroam/
  #   sudo nmcli connection modify "$conn" \
  #     802-1x.client-cert /etc/eduroam/(basename $key) \
  #     802-1x.private-key /etc/eduroam/(basename $key) \
  #     802-1x.private-key-password "$pw"
  #   rm -rf ~/.joinnow
  # Only the .p12 is needed: it is a PKCS#12 bundle (key + client cert + chain),
  # so the separate .crt is not copied, and client-cert and private-key both
  # point at the .p12. Set all three in ONE nmcli call, as above.
  # Repeat after each renewal (running the script again resets the paths).
  services.envfs.enable = true;
}
