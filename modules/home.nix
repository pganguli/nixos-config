{ ... }: {
  home-manager.useGlobalPkgs = true;     # use the system's nixpkgs and its settings
  home-manager.useUserPackages = true;   # install user packages to /etc/profiles
  home-manager.backupFileExtension = "backup";   # rename old files, do not fail
  home-manager.users.pganguli = import ../home/pganguli.nix;
}
