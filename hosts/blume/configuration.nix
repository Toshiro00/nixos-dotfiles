# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # External
      ../../modules
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs"];
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr"; # Best for unstable/laggy links
  };

  fileSystems."/" = { device = "zroot/root"; fsType = "zfs"; };
  fileSystems."/nix" = { device = "zroot/nix"; fsType = "zfs"; };
  fileSystems."/home" = { device = "zroot/home"; fsType = "zfs"; };
  fileSystems."/var/lib/libvirt/images" = { device = "zroot/vms"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/DE2A-C8EE"; fsType = "vfat"; };
  
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.hostName = "blume";
  networking.hostId = "c705ba5e";



  system.stateVersion = "25.11"; # Did you read the comment?

}

