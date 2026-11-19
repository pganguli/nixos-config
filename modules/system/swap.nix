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

  # Out of memory: with this much swap a runaway job would grind through it and
  # freeze the desktop before the kernel kills anything. oomd kills the app (its
  # cgroup) with the worst memory pressure in the user session instead.
  # Services (system.slice) are not watched.
  systemd.oomd.enableUserSlices = true;

  # swappiness 10: under memory pressure, reclaim file page cache before swapping out program memory.
  # vfs_cache_pressure 50: reclaim dentry/inode caches half as eagerly as the default (100).
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };
}
