{
  config,
  pkgs,
  ...
}:
{
  rebuild = {
    owner = "dashalev";
  };

  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "127.0.0.1";
      MusicFolder = "/media/mus";
    };
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts."mus.dashalev.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:4533
    '';
  };

  preservation = {
    enable = true;
    preserveAt."/nix/persist" = {
      directories = [
        {
          directory = config.users.users.dashalev.home;
          user = "dashalev";
          group = "users";
        }
        {
          directory = "/media";
          user = "dashalev";
          group = "users";
        }
        {
          directory = "/media/mus";
          user = "dashalev";
          group = "navidrome";
          mode = "0755";
        }
      ];
    };
  };

  fileSystems."/".neededForBoot = true;

  users.users = {
    dashalev = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "wheel"
        "networkmanager"
        "input"
      ];
      shell = pkgs.fishMinimal;
      initialPassword = "boobs";

      maid = {
        imports = [ ../../modules/maid/dashalev ];

        shell = {
          color = "green";
          icon = "🖥️";
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
