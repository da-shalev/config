{
  pkgs,
  lib,
  ...
}:
{
  networking.networkmanager = {
    enable = true;
  };

  rebuild = {
    bundleConfig = true;
    owner = "nixos";
  };

  image.baseName = lib.mkForce "q";
  isoImage = {
    volumeID = lib.mkForce "QISO";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  users.users = {
    nixos = {
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
        "networkmanager"
      ];
      shell = pkgs.fishMinimal;

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
