{
  config,
  pkgs,
  lib,
  ...
}:
{
  preservation = {
    enable = true;
    preserveAt."/nix/persist".directories = [
      {
        directory = config.users.users.dashalev.home;
        user = "dashalev";
        group = "users";
      }
    ];
  };

  fileSystems =
    let
      home = config.users.users.dashalev.home;
    in
    {
      "/".neededForBoot = true;
      "${home}/media/vms" = {
        device = "/dev/disk/by-partlabel/disk-foozilla-gaming";
        fsType = "xfs";
        options = [
          "defaults"
          "nofail"
        ];
      };

      "${home}/media/entertainment" = {
        device = "/dev/disk/by-partlabel/disk-tomatoes-media";
        fsType = "xfs";
        options = [
          "defaults"
          "nofail"
        ];
      };
    };

  users.users = {
    # USER: nwll - dashalev
    dashalev = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "networkmanager"
        "kvm"
        "input"
        "docker"
      ];
      shell = pkgs.fish;
      initialPassword = "boobs";
    };
  };

  system.stateVersion = "24.05";
}
