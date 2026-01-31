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
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
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
      shell = pkgs.fishMinimal;
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
          extraConfig = ./hyprland.conf;
        };

        wayland = {
          enable = true;
          cursor_theme.size = 40;
        };
      };
    };
  };
}
