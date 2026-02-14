{ pkgs, ... }:
{
  time.timeZone = "Europe/Istanbul";

  users.users.bagley = {
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" "libvirtd" ];
    shell = pkgs.fish;
  };
}
