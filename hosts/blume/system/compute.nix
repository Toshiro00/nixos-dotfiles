{ pkgs, ... }:
{
  # Host-side AMDGPU/ROCm runtime. Containers consume /dev/kfd and /dev/dri.
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  environment.systemPackages = with pkgs; [
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
  ];
}
