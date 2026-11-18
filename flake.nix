{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
