{ pkgs, ... }:
let
  gpuBindMounts = {
    "/dev/dri" = {
      hostPath = "/dev/dri";
      isReadOnly = false;
    };
    "/dev/kfd" = {
      hostPath = "/dev/kfd";
      isReadOnly = false;
    };
  };

  gpuAllowedDevices = [
    {
      node = "char-drm";
      modifier = "rwm";
    }
    {
      node = "char-kfd";
      modifier = "rwm";
    }
    {
      node = "char-fb";
      modifier = "rwm";
    }
  ];
in
{
  containers.llama = {
    autoStart = false;
    privateNetwork = true;
    hostAddress = "10.233.20.1";
    localAddress = "10.233.20.2";
    bindMounts = gpuBindMounts;
    allowedDevices = gpuAllowedDevices;

    config = { pkgs, ... }: {
      services.llama-cpp = {
        enable = true;
        package = pkgs.llama-cpp-rocm;
        host = "0.0.0.0";
        port = 8080;
        openFirewall = true;
        modelsDir = "/var/lib/llama-cpp/models";
        extraFlags = [
          "--no-webui"
        ];
      };

      system.stateVersion = "25.11";
    };
  };
}
