{ pkgs, ... }: {
  # Fish is installed, but it is not the login shell
  programs.fish.enable = true;

  # tmux starts fish directly
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-shell ${pkgs.fish}/bin/fish
    '';
  };
}
