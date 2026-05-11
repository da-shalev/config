{ lib, pkgs, ... }:
{
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    diskSize = 16384;
    graphics = true;
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  preservation.enable = lib.mkForce false;
  fileSystems = lib.mkForce { };

  rebuild = {
    bundleConfig = true;
    owner = "dashalev";
  };

  users.users = {
    dashalev = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "wheel"
        "video"
        "networkmanager"
        "kvm"
        "input"
        "docker"
        "audio"
      ];
      shell = pkgs.fishMinimal;
      initialPassword = "boobs";

      maid = {
        imports = [ ../../modules/maid/dashalev ];

        shell = {
          color = "cyan";
          icon = "💿";
        };

        hyprland.enable = true;
        wayland.enable = true;
      };
    };
  };

  system.stateVersion = "26.05";
}
