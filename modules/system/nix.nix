{ inputs, ... }: {
  # "nix develop esp-dev#esp32s3-idf" uses the version locked in flake.lock
  nix.registry.esp-dev.flake = inputs.nixpkgs-esp-dev;

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
  # SEGGER's J-Link tools bundle Qt 4 (end of life), which nixpkgs marks as insecure. Only the
  # GUI tools use it (JLinkConfig, J-Flash...), not JLinkExe or the GDB server. The name has
  # the version in it: when segger-jlink updates, the build fails with the new name; change it here.
  nixpkgs.config.permittedInsecurePackages = [ "segger-jlink-qt4-874" ];

  # Lets downloaded binaries run (uv Python, Zed extensions and language servers)
  programs.nix-ld.enable = true;

  # Lets scripts find programs at fixed paths such as /usr/bin/openssl or /bin/bash.
  # /usr/bin and /bin show the programs in the PATH of the program that looks.
  #
  # Needed by the UNC eduroam enrollment script (SecureW2 JoinNow .run file):
  # it looks for python (with dbus), openssl, xdg-open and wpa_supplicant only
  # in /bin, /usr/bin and /usr/sbin. Run it as your user: sh SecureW2_JoinNow.run
  #
  # wpa_supplicant is no longer installed (iwd does the Wi-Fi). If the enrollment
  # script then complains that it can't find it, add pkgs.wpa_supplicant back
  # to environment.systemPackages; this was not tested.
  #
  # After enrollment, run "sudo eduroam-iwd" (modules/system/eduroam.nix): iwd,
  # the Wi-Fi backend (hosts/lenowo), can't read the .p12 that the script leaves in
  # the NetworkManager profile, and the command converts it. Do the same after
  # each renewal. Check with: journalctl -u iwd -b  (look for "eapSuccess";
  # "Error loading client private key" means a bad key file or password).
  services.envfs.enable = true;
}
