{ ... }: {
  users.users.pganguli = {
    isNormalUser = true;
    description = "Prateek Ganguli";
    # dialout: serial ports (/dev/ttyUSB*, /dev/ttyACM*) for microcontroller boards
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" "dialout" ];
  };
}
