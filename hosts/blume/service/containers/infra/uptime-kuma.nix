{ ... }:
{
  containers.uptime-kuma = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.50.1";
    localAddress = "10.233.50.2";
    forwardPorts = [
      {
        containerPort = 3001;
        hostPort = 8082;
        protocol = "tcp";
      }
    ];
    config = { ... }: {
      services.uptime-kuma = {
        enable = true;
        settings = {
          HOST = "0.0.0.0";
          PORT = "3001";
        };
      };
      networking.firewall.allowedTCPPorts = [ 3001 ];
      system.stateVersion = "25.11";
    };
  };
}
