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
    # VPN: Cisco AnyConnect and compatible servers (Plasma's network applet gets
    # an "OpenConnect" option when adding a VPN connection)
    plugins = [ pkgs.networkmanager-openconnect ];
  };

  # Fixed regulatory domain: otherwise cfg80211 flips between WORLD and the
  # AP's country IE, and 6 GHz association (blocked under WORLD) fails with
  # "Association request to the driver failed" + rtw89 "failed to wait RF IQK".
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=US";

  # Do not change
  system.stateVersion = "26.05";
}
