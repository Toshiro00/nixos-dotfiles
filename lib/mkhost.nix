{ nixpkgs, home-manager }:
{ system, hostName, userName ? null, extraModules ? [ ] }:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit hostName userName;
  };

  modules =
    [
      ./../hosts/common
      ./../hosts/${hostName}
      ./../modules
      ({ networking.hostName = hostName; })
    ]
    ++ nixpkgs.lib.optionals (userName != null) [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${userName} = import ./../users/${userName};
      }
    ]
    ++ extraModules;
}
