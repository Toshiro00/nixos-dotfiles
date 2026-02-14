{ lib, pkgs, ... }:
{
  imports = [
    ./containers/system/ctos.nix
    ./containers/ai/llama.nix
    ./containers/infra/homepage.nix
    ./containers/infra/uptime-kuma.nix
    ./containers/security/vaultwarden.nix
  ];

  blume.container.enable = true;

  networking.firewall.allowedTCPPorts = [
    8081 # Homepage
    8082 # Uptime Kuma
    8083 # Vaultwarden
  ];
}
