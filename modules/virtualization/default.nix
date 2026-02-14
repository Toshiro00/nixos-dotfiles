{ lib, config, pkgs, ... }:
let
  cfg = config.blume.virtualization;
in
{
  options.blume.virtualization = {
    enable = lib.mkEnableOption "Blume virtualization profile";

    windows.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Windows-friendly libvirt/qemu defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.libvirtd.qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = cfg.windows.enable;
    };
  };
}
