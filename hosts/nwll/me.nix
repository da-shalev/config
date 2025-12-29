{
  config,
  pkgs,
  ...
}:
let
  sources = import ../../npins;
  hyprland =
    (import sources.flake-compat {
      src = sources.Hyprland;
    }).defaultNix;
in
{
  imports = [
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/disable-sleep.nix
    hyprland.nixosModules.default
  ];

  programs.fish = {
    enable = true;
    package = pkgs.fishMinimal;
  };

  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

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
            monitor=DP-1,highres@highrr,auto,1
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
