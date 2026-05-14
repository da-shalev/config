{ lib, config, ... }:
{
  environment = {
    localBinInPath = true;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  environment.defaultPackages = [ ];

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
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/var/lib/systemd/random-seed";
        how = "symlink";
        inInitrd = true;
        configureParent = true;
      }
      { file = "/etc/machine-id"; inInitrd = true; }
    ];
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
