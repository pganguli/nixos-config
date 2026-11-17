{ pkgs, ... }: {
  # Fish is installed, but it is not the login shell
  programs.fish.enable = true;

  # Alacritty starts fish directly
  environment.etc."alacritty/alacritty.toml".text = ''
    [terminal.shell]
    program = "${pkgs.fish}/bin/fish"
  '';

  # tmux starts fish directly
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-shell ${pkgs.fish}/bin/fish
    '';
  };
}
