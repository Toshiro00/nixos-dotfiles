{ pkgs, ... }:
{
  containers.homepage = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.40.1";
    localAddress = "10.233.40.2";
    forwardPorts = [
      {
        containerPort = 8082;
        hostPort = 8081;
        protocol = "tcp";
      }
    ];
    config = { pkgs, lib, ... }: {
      services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        settings = {
          title = "ctOS Dashboard";
          base = "http://10.0.0.241:8081";
          background = {
            image = "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=2070&auto=format&fit=crop"; # Technic/Matrix vibe
            opacity = 50;
          };
        };
        services = [
          {
            "Infrastructure" = [
              {
                "Uptime Kuma" = {
                  icon = "uptime-kuma.png";
                  href = "http://10.0.0.241:8082";
                  description = "System Monitoring";
                };
              }
            ];
          }
          {
            "Security" = [
              {
                "Vaultwarden" = {
                  icon = "vaultwarden.png";
                  href = "http://10.0.0.241:8083";
                  description = "Sensitive Data Vault";
                };
              }
            ];
          }
        ];
      };
      systemd.services.homepage-dashboard.environment = {
        HOMEPAGE_ALLOWED_HOSTS = lib.mkForce "blume,10.0.0.241,localhost,127.0.0.1,blume:8081";
      };
      networking.firewall.allowedTCPPorts = [ 8082 ];
      system.stateVersion = "25.11";
    };
  };
}
