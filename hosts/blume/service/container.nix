{ lib, pkgs, ... }:
{
  imports = [
    ./containers/system/ctos.nix
    ./containers/ai/llama.nix
    ./containers/ai/llama-dev.nix
    ./containers/infra/homepage.nix
    ./containers/infra/uptime-kuma.nix
    ./containers/security/vaultwarden.nix
  ];

  blume.container.enable = true;

  # Put this in your HOST configuration.nix
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-*" ];
    externalInterface = "enp6s0"; # Make sure this is your actual internet interface!
  };

  networking.firewall.allowedTCPPorts = [
    8081 # Homepage
    8082 # Uptime Kuma
    8083 # Vaultwarden
    8084 # llama-dev
    2022 # llama-dev SSH
  ];
}
