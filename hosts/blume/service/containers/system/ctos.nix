{ pkgs, ... }:
{
  containers.ctos = {
    autoStart = false;
    privateNetwork = true;
    hostAddress = "10.233.0.1";
    localAddress = "10.233.0.2";

    config = { ... }: {
      services.openssh.enable = true;
      environment.systemPackages = with pkgs; [
        curl
        helix
      ];
      system.stateVersion = "25.11";
    };
  };
}
