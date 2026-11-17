{ ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  # Lets downloaded binaries run (uv Python, Zed extensions and language servers)
  programs.nix-ld.enable = true;

  # Lets scripts find programs at fixed paths such as /usr/bin/openssl or /bin/bash.
  # /usr/bin and /bin show the programs in the PATH of the program that looks.
  services.envfs.enable = true;
}
