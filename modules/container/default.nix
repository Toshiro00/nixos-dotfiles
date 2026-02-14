{ lib, config, ... }:
let
  cfg = config.blume.container;
in
{
  options.blume.container.enable = lib.mkEnableOption "Blume container profile";

  config = lib.mkIf cfg.enable {
    boot.enableContainers = true;
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp6s0";
      forwardPorts = [
        { sourcePort = 8081; destination = "10.233.40.2:8082"; proto = "tcp"; }
        { sourcePort = 8082; destination = "10.233.50.2:3001"; proto = "tcp"; }
        { sourcePort = 8083; destination = "10.233.60.2:8000"; proto = "tcp"; }
      ];
    };

    networking.firewall.trustedInterfaces = [ "ve-+" ];
  };
}
