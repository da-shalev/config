{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/disable-sleep.nix
  ];

  programs = {
    fish = {
      enable = true;
      package = pkgs.fishMinimal;
    };

    steam.enable = true;
    hyprland.enable = true;
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.stable.mullvad-vpn;
  };

  rebuild.owner = "dashalev";

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

  fileSystems = {
    "/".neededForBoot = true;
    "/home/dashalev/media/vms" = {
      device = "/dev/disk/by-partlabel/disk-foozilla-gaming";
      fsType = "xfs";
      options = [
        "defaults"
        "nofail"
      ];
    };

    "/home/dashalev/media/entertainment" = {
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

      maid = {
        imports = [ ../../modules/maid/dashalev ];

        shell = {
          package = pkgs.fishMinimal;
          color = "magenta";
          icon = "🗿";
        };

        hyprland = {
          enable = true;
          extraConfig = ''
            monitor=DP-1,highres@highrr,auto,1,bitdepth,10
            env=GSK_RENDERER,ngl
          '';
        };

        wayland = {
          enable = true;
          cursor_theme.size = 40;
        };
      };
    };
  };
}
