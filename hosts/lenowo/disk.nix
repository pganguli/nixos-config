# Hand-written facts about this machine's disk.
# hardware-configuration.nix is generated; do not put these there.
{ config, lib, ... }:
let
  # LUKS device under /, taken from hardware-configuration.nix
  rootLuksName = lib.removePrefix "/dev/mapper/" config.fileSystems."/".device;
in {
  # Let TRIM pass through LUKS to the SSD
  boot.initrd.luks.devices.${rootLuksName}.allowDiscards = true;

  # Hibernation: position of /swap/swapfile on the disk.
  # Get it again if you make the swap file again:
  #   sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
  boot.kernelParams = [ "resume_offset=1067369" ];
}
