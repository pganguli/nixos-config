{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # For the odd package newer than the release has (Julia 1.13, modules/dev/languages.nix)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";   # use the same nixpkgs as the system
    };
    # Declarative KDE Plasma settings (shortcuts, KWin, input, power) for Home Manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # MATLAB: an FHS environment for the MathWorks installer and MATLAB
    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Code CLI: tracks upstream releases faster than nixpkgs
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    # ESP-IDF (nixpkgs has none): dev shells, used with "nix develop esp-dev#esp32s3-idf".
    # No "follows": it is built against its own nixpkgs (25.11), and the shells are
    # not part of the system, so they do not need to match this one.
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    # Sources for the bare-metal nRF54 build (Projects/nrf54-pwrbench): Nordic's MDK and CMSIS
    # headers. Not flakes; modules/dev/languages.nix exports them as $NRFX and $CMSIS.
    nrfx = { url = "github:NordicSemiconductor/nrfx"; flake = false; };
    cmsis = { url = "github:ARM-software/CMSIS_6"; flake = false; };
  };

  outputs = { nixpkgs, home-manager, claude-code-nix, ... }@inputs: {
    nixosConfigurations.lenowo = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/lenowo
        home-manager.nixosModules.home-manager
        { nixpkgs.overlays = [ claude-code-nix.overlays.default ]; }
      ];
    };
  };
}
