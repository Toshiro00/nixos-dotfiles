{ ... }:
{
  containers.vaultwarden = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.60.1";
    localAddress = "10.233.60.2";
    forwardPorts = [
      {
        containerPort = 8000;
        hostPort = 8083;
        protocol = "tcp";
      }
    ];
    config = { ... }: {
      services.vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "http://blume:8083";
          SIGNUPS_ALLOWED = true;
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8000;
        };
      };
      networking.firewall.allowedTCPPorts = [ 8000 ];
      system.stateVersion = "25.11";
    };
  };
}
