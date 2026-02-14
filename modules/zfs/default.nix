
{ config, pkgs, ... }:

{
  # Declarative ZFS Tuning
  systemd.services.zfs-tuning = {
    description = "Apply Blume-standard ZFS optimizations";
    after = [ "zfs-mount.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.zfs}/bin/zfs set recordsize=64k zroot/vms
      ${pkgs.zfs}/bin/zfs set logbias=latency zroot/vms
    '';
  };
}
