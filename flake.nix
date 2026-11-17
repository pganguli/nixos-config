{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";   # use the same nixpkgs as the system
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.lenowo = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/lenowo
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
