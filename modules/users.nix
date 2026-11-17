{ pkgs, ... }: {
  users.users.pganguli = {
    isNormalUser = true;
    description = "Prateek Ganguli";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" ];
  };
}
