{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ./laptop.nix
    ../../modules/nix.nix
    ../../modules/users.nix
    ../../modules/locale.nix
    ../../modules/desktop.nix
    ../../modules/shell.nix
    ../../modules/cli.nix
    ../../modules/gui.nix
    ../../modules/dev.nix
    ../../modules/storage.nix
    ../../modules/swap.nix
    ../../modules/power.nix
    ../../modules/security.nix
    ../../modules/home.nix
    ../../modules/matlab.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;   # LTS kernel; the NVIDIA driver supports it

  # Network
  networking.hostName = "lenowo";
  networking.networkmanager.enable = true;

  # Fixed regulatory domain: otherwise cfg80211 flips between WORLD and the
  # AP's country IE, and 6 GHz association (blocked under WORLD) fails with
  # "Association request to the driver failed" + rtw89 "failed to wait RF IQK".
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=US";

  # Do not change
  system.stateVersion = "26.05";
}
