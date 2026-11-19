{ pkgs, ... }: {
  # Fish is installed, but it is not the login shell
  programs.fish.enable = true;
}
