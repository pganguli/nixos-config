{ ... }: {
  home-manager.useGlobalPkgs = true;        # use the system's nixpkgs and its settings
  home-manager.useUserPackages = true;      # install user packages to /etc/profiles
  home-manager.backupFileExtension = "bak"; # rename old files, do not fail
  home-manager.users.pganguli = import ../home/pganguli.nix;
}
