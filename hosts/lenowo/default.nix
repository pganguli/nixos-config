{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ./laptop.nix
    ../../modules
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;   # LTS kernel; the NVIDIA driver supports it
  # Magic SysRq bitmask 176 = 16 (sync) + 32 (remount read-only) + 128 (reboot/power off)
  boot.kernel.sysctl."kernel.sysrq" = 176;

  # Network
  networking.hostName = "lenowo";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";   # instead of wpa_supplicant
    # VPN: Cisco AnyConnect and compatible servers (Plasma's network applet gets
    # an "OpenConnect" option when adding a VPN connection)
    plugins = [ pkgs.networkmanager-openconnect ];
  };

  # The VPN profile's "CSD trojan binary" field defaults to
  # /usr/libexec/openconnect/csd-post.sh, which NixOS doesn't have. The scripts
  # live in the store at a path that changes with every openconnect update, so
  # this symlink gives a stable one.
  # csd-post.sh pulls the hostscan token out of the server's XML with
  # xmlstarlet. Without it the token is empty, the login that follows has no
  # "auth" node in the reply, and it only works on a retry.
  environment.systemPackages = [ pkgs.xmlstarlet ];

  systemd.tmpfiles.rules = [
    "d /usr/libexec 0755 root root -"
    "L+ /usr/libexec/openconnect - - - - ${pkgs.openconnect}/libexec/openconnect"
  ];

  # Fixed regulatory domain: otherwise cfg80211 flips between WORLD and the
  # AP's country IE, and 6 GHz association (blocked under WORLD) fails with
  # "Association request to the driver failed" + rtw89 "failed to wait RF IQK".
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=US";

  # No 6 GHz. Measured on 2026-11-23: iwd kept roaming from the 5 GHz BSS to the
  # same AP's 6 GHz one (it ranks higher), where rx fell to 6 Mbit/s and pings got
  # no replies for ~7 s (5 s on 6 GHz, then ~3 s disconnected), then back to 5 GHz, over and over. 0.0 disables the band.
  # Remove this line to try 6 GHz again (e.g. after a kernel update for rtw89).
  networking.wireless.iwd.settings.Rank.BandModifier6GHz = 0.0;

  # The driver's idle RSSI flips between about -48 and -82 dBm on the same AP
  # while link rates and ping stay normal (measured 2026-11-23), which kept
  # crossing iwd's 5 GHz roam thresholds (-76 / -82), so iwd roamed to flaky
  # APs and dropped the link. Thresholds below the -82/-83 readings stop that.
  # Cost: iwd holds on to a really weak AP longer. Defaults: -76 and -82.
  networking.wireless.iwd.settings.General = {
    RoamThreshold5G = -88;
    CriticalRoamThreshold5G = -90;
  };

  # Do not change
  system.stateVersion = "26.05";
}
