{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    blacklistedKernelModules = [
      # prevent amdgpu drivers from being loaded, disable igpu
      "amdgpu"
      # blacklist its audio module
      "snd_hda_intel"
    ];

    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "uas"
      ];
      unl0kr.allowVendorDrivers = true;
    };

    tmp.cleanOnBoot = true;
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

    kernelParams = [
      # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
      "split_lock_detect=off"
    ];
  };

  services.userborn.enable = true;

  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    scx = {
      package = pkgs.stable.scx.rustscheds;
      enable = true;
      scheduler = "scx_lavd";
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      extraPackages32 = with pkgs; [ nvidia-vaapi-driver ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
}
