{
  config,
  pkgs,
  ...
}:
{
  rebuild = {
    owner = "dashalev";
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
