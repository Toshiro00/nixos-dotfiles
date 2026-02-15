{
  description = "Blume Corporation NixOS Fleet";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscodium-server = {
      url = "github:unicap/nixos-vscodium-server";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      vscodium-server,
      ...
    }@inputs:
    let
      mkhost = import ./lib/mkhost.nix { inherit nixpkgs home-manager inputs; };
    in
    {
      nixosConfigurations = {
        blume = mkhost {
          system = "x86_64-linux";
          hostName = "blume";
          userName = "bagley";
        };
      };
    };
}
