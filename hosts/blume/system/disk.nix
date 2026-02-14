{ ... }:
{
  fileSystems."/" = { device = "zroot/root"; fsType = "zfs"; };
  fileSystems."/nix" = { device = "zroot/nix"; fsType = "zfs"; };
  fileSystems."/home" = { device = "zroot/home"; fsType = "zfs"; };
  fileSystems."/var/lib/libvirt/images" = { device = "zroot/vms"; fsType = "zfs"; };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/DE2A-C8EE"; fsType = "vfat"; };
}
