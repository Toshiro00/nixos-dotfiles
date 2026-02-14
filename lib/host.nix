
{
  description = "Blume Corporation NixOS Fleet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    mkHost = import ./lib/mkHost.nix { inherit nixpkgs home-manager; };
  in
  {
    nixosConfigurations = {
      blume = mkHost {
        system = "x86_64-linux";
        hostName = "blume";
        userName = "bagley";
      };
    };
  };
}
