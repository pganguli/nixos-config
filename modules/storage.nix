{ pkgs, ... }: {
  # Btrfs mount options (these merge with hardware-configuration.nix)
  fileSystems."/".options     = [ "compress=zstd" "noatime" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" ];
  fileSystems."/nix".options  = [ "compress=zstd" "noatime" ];

  # Weekly TRIM
  services.fstrim.enable = true;

  # Monthly btrfs scrub. All three mounts are on one filesystem, so scrub it once.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Limit the size of the system logs
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  # Tools
  environment.systemPackages = with pkgs; [
    compsize   # shows btrfs compression ratio
  ];
}
