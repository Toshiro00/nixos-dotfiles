{ inputs, ... }:
let
  gpuBindMounts = {
    # 1. The Physical Devices
    "/dev/dri" = {
      hostPath = "/dev/dri";
      isReadOnly = false;
    };
    "/dev/kfd" = {
      hostPath = "/dev/kfd";
      isReadOnly = false;
    };

    # 2. The Sysfs Topology (CRITICAL FOR ROCm)
    # nspawn hides these by default, so we must explicitly pass them through.
    # We need both class and virtual/kfd because /sys/class/kfd is just a folder of symlinks.
    "/sys/class/kfd" = {
      hostPath = "/sys/class/kfd";
      isReadOnly = true;
    };
    "/sys/devices/virtual/kfd" = {
      hostPath = "/sys/devices/virtual/kfd";
      isReadOnly = true;
    };
    "/sys/module/amdgpu" = {
      hostPath = "/sys/module/amdgpu";
      isReadOnly = true;
    };
  };

  gpuAllowedDevices = [
    {
      node = "char-drm";
      modifier = "rwm";
    }
    {
      # systemd doesn't know what "char-kfd" is.
      # We must use the absolute path for the cgroup whitelist to work.
      node = "/dev/kfd";
      modifier = "rwm";
    }
    {
      node = "char-fb";
      modifier = "rwm";
    }
  ];
in
{
  containers.llama-dev = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.21.1";
    localAddress = "10.233.21.2";
    forwardPorts = [
      {
        containerPort = 8080;
        hostPort = 8084;
        protocol = "tcp";
      }
      {
        containerPort = 22;
        hostPort = 2022;
        protocol = "tcp";
      }
    ];
    bindMounts = gpuBindMounts;
    allowedDevices = gpuAllowedDevices;

    config =
      { pkgs, ... }:
      {
        programs.nix-ld.enable = true;

        # 1. THE MAGIC: Tell NixOS to link C++ headers, libraries,
        # and CMake files into the global container environment
        environment.pathsToLink = [
          "/include"
          "/lib"
          "/lib/cmake"
        ];

        # 2. Tell CMake and HIP where to look for those newly linked files
        environment.variables = {
          CMAKE_PREFIX_PATH = "/run/current-system/sw";
          ROCM_PATH = "${pkgs.rocmPackages.clr}";
          HIP_DEV_LIB = "${pkgs.rocmPackages.rocm-device-libs}/amdgcn/bitcode";
        };

        environment.systemPackages = with pkgs; [
          # Version Control
          git
          tig

          # Editors & Terminal
          vim
          tmux
          htop
          ripgrep
          fd
          eza

          # Build Tools
          cmake
          ninja
          gnumake
          gcc
          pkg-config
          ccache # Added this to squelch your CMake warning!

          # ROCm tools & libs (Added the missing math libraries for compilation)
          rocmPackages.rocminfo
          rocmPackages.rocm-smi
          rocmPackages.clr
          rocmPackages.hipcc
          rocmPackages.hipblas
          rocmPackages.hipblas-common
          rocmPackages.rocblas
          rocmPackages.rocm-device-libs

          # Python
          (python3.withPackages (
            ps: with ps; [
              numpy
              pip
              setuptools
            ]
          ))

          # Utilities
          wget
          curl
          pciutils
          usbutils
          radeontop
        ];

        # Enable SSH for easy access
        services.openssh.enable = true;
        services.openssh.settings = {
          PermitRootLogin = "prohibit-password";
        };

        networking.nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        networking.firewall.allowedTCPPorts = [
          22
          8080
        ];

        system.stateVersion = "25.11"; # Note: Make sure you are using an unstable channel for the latest ROCm fixes
      };
  };
}
