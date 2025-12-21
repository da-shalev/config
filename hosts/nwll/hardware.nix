{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      systemd.enable = true;
    };
  };

  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };

  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      wacom.enable = true;
    };
    scx = {
      package = pkgs.stable.scx.rustscheds;
      enable = true;
      scheduler = "scx_lavd";
    };
  };

  boot = {
    tmp.cleanOnBoot = true;
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

    kernelParams = [
      # laptops and dekstops don't need Watchdog
      "nowatchdog"
      # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
      "split_lock_detect=off"
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;

    graphics = {
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

  boot = {
    initrd = {
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
  };

  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
