{ config, ... }:
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];

    # enable AMD IOMMU hardware + passthrough mode
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];

    kernelModules = [
      # load VFIO driver for device passthrough
      "vfio-pci"
      # looking glass kernel module
      "kvmfr"
    ];

    blacklistedKernelModules = [
      # prevent amdgpu drivers from being loaded, disable igpu
      "amdgpu"
      # blacklist its audio module
      "snd_hda_intel"
    ];

    # lspci | grep "Radeon Graphics"
    # lspci -n -s 79:00.0
    # lspci -n -s 79:00.1
    extraModprobeConfig = ''
      options vfio-pci ids=1002:13c0,1002:1640
      options kvmfr static_size_mb=256
    '';
  };

  # add group "kvm" to gain permission to access the actual gpu device
  services.udev.extraRules = ''
    SUBSYSTEM=="vfio", GROUP="kvm", MODE="0660"
    SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660"
  '';

  # increase pathetic 8MB of vram limit for VMS
  systemd.settings.Manager.DefaultLimitMEMLOCK = "infinity";
}
