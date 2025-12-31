{
  lib,
  config,
  pkgs,
  ...
}:
{
  environment = {
    localBinInPath = true;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  maid.sharedModules = [
    ../maid/shell
    ../maid/wayland
    ../maid/tmux
    ../maid/fish
    ../maid/hyprland
    ../maid/vicinae
  ];

  environment.defaultPackages = [
  ]
  ++ lib.optionals config.services.mullvad-vpn.enable [ pkgs.mullvad-vpn ];

  # automates preservation for commonly used NixOS options
  preservation.preserveAt."/nix/persist" = {
    commonMountOptions = [
      "x-gvfs-hide"
      "x-gdu.hide"
    ];

    directories = [
      "/var/log"
      "/var/lib/systemd/coredump"
      {
        directory = "/tmp";
        mode = "1777";
      }
    ]
    ++ lib.optionals config.networking.networkmanager.enable [
      "/var/lib/NetworkManager/"
      "/etc/NetworkManager/"
    ]
    ++ lib.optionals config.hardware.bluetooth.enable [ "/var/lib/bluetooth/" ]
    ++ lib.optionals config.services.mullvad-vpn.enable [
      "/etc/mullvad-vpn"
      "/var/cache/mullvad-vpn"
    ]
    ++ lib.optionals config.virtualisation.docker.enable [
      {
        directory = "/var/lib/docker";
        mode = "1777";
      }
    ];
    files = [
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
      {
        file = "/etc/machine-id";
        inInitrd = true;
        how = "symlink";
        configureParent = true;
      }
    ];
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
