{ config, ... }: {
  # Swap file on btrfs (made with "btrfs filesystem mkswapfile")
  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Hibernation: resume from the device that holds the swap file
  boot.resumeDevice = config.fileSystems."/".device;

  # zswap: compress pages in RAM before they go to swap
  systemd.tmpfiles.rules = [
    "w /sys/module/zswap/parameters/compressor       - - - - zstd"
    "w /sys/module/zswap/parameters/max_pool_percent - - - - 20"
    "w /sys/module/zswap/parameters/enabled          - - - - 1"
  ];
}
