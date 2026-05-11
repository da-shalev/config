{ config, lib, ... }:
{
  disabledModules = [ "installer/cd-dvd/channel.nix" ];

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    cpu.amd.updateMicrocode = true;
    bluetooth.enable = true;

    graphics.enable = true;
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nouveau"
    "modesetting"
  ];

  specialisation.nvidia-modern.configuration = {
    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    services.xserver.videoDrivers = lib.mkForce [
      "nvidia"
      "amdgpu"
      "modesetting"
    ];
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
    };
  };

}
