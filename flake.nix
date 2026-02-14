{
  description = "Blume Corporation NixOS Fleet";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    mkhost = import ./lib/mkhost.nix { inherit nixpkgs home-manager; };
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
