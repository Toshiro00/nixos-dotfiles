{ ... }:
{
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  networking.hostId = "c705ba5e";

  # Enable mDNS for easy access from laptop via blume.local
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    openFirewall = true;
  };
}
