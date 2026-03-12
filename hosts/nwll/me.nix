{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/disable-sleep.nix
    ../../modules/nixos/convex.nix
  ];

  services.convex.enable = true;

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    hyprland.enable = true;
  };

  services = {
    syncthing = {
      enable = true;
      user = "dashalev";
      dataDir = config.users.users.dashalev.home;
      openDefaultPorts = true;
      settings = {
        devices."android".id = "N5EM67F-W5T7BEE-XW747IA-U55OJIM-UFZ2C3M-ECGV52P-QQXCHL7-ETODIQ6";
        devices."macbook".id = "66CZCNP-VXJD72V-7CVQ3OH-66KYE46-REWGZ3X-VNVLPSA-GKSBBDP-7L66EAP";
        folders."music" = {
          path = "${config.users.users.dashalev.home}/media/mus";
          label = "Music";
          type = "sendonly";
          devices = [
            "android"
            "macbook"
          ];
          ignorePatterns = [ ".thumbnails" ];
        };
        folders."documents" = {
          path = "${config.users.users.dashalev.home}/media/dox";
          label = "Documents";
          devices = [
            "android"
            "macbook"
          ];
        };
      };
    };

    samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = true;
      settings = {
        global = {
          security = "user";
          "map to guest" = "Bad Password";
          "socket options" = "TCP_NODELAY";
          "use sendfile" = "yes";
        };
        entertainment = {
          path = "/entertainment";
          "guest ok" = "yes";
          "guest only" = "yes";
          "read only" = "yes";
          browseable = "yes";
        };
      };
    };

    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://${config.networking.hostName}:2586";
        listen-http = "0.0.0.0:2586";
      };
    };

    smartd = {
      enable = true;
      notifications = {
        wall.enable = false;
        x11.enable = true;
        test = false;
      };
      defaults.monitored = "-a -m root -M exec ${pkgs.writeShellScript "smartd-notify" ''
        ${lib.getExe config.rebuild.notify} "Disk health warning" "warning" "max" "$SMARTD_MESSAGE"
      ''}";
    };

    mullvad-vpn = {
      enable = true;
      package = pkgs.stable.mullvad-vpn;
    };

  };

  power.ups = {
    enable = true;
    mode = "standalone";
    ups.cyberpower = {
      driver = "usbhid-ups";
      port = "auto";
    };
    upsmon = {
      monitor.cyberpower = {
        system = "cyberpower@localhost";
        powerValue = 1;
        user = "upsmon";
      };
      settings = {
        NOTIFYCMD = "p=high; case $NOTIFYTYPE in LOWBATT|FSD) p=max;; esac; ${lib.getExe config.rebuild.notify} \"UPS: $NOTIFYTYPE\" \"electric_plug\" \"$p\"";
        NOTIFYFLAG = [
          [
            "ONLINE"
            "SYSLOG+EXEC"
          ]
          [
            "ONBATT"
            "SYSLOG+EXEC"
          ]
          [
            "LOWBATT"
            "SYSLOG+EXEC"
          ]
          [
            "REPLBATT"
            "SYSLOG+EXEC"
          ]
          [
            "FSD"
            "SYSLOG+EXEC"
          ]
        ];
      };
    };
    users.upsmon = {
      passwordFile = "/dev/null";
      upsmon = "primary";
    };
  };

  security.pam.services.sshd.rules.session.ntfy-notify = {
    order = 12300;
    control = "optional";
    modulePath = "pam_exec.so";
    args = [
      "seteuid"
      "${pkgs.writeShellScript "ssh-notify" ''
        if [ "$PAM_TYPE" = "open_session" ]; then
          ${lib.getExe config.rebuild.notify} "SSH login" "rotating_light" "high" "$PAM_USER from ''${PAM_RHOST:-local}"
        fi
      ''}"
    ];
  };

  systemd.services = {
    upsdrv.serviceConfig.SuccessExitStatus = "1";

    ntfy-boot = {
      description = "Notify on system startup";
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "multi-user.target"
        "ntfy-sh.service"
      ];
      requires = [ "ntfy-sh.service" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe config.rebuild.notify} \"System started\" \"green_circle\" \"default\" \"${config.networking.hostName} is online\"";
      };
    };

    ntfy-shutdown = {
      description = "Notify on system shutdown";
      after = [ "ntfy-sh.service" ];
      requires = [ "ntfy-sh.service" ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe' pkgs.coreutils "true"}";
        ExecStop = "${lib.getExe config.rebuild.notify} \"System shutting down\" \"red_circle\" \"high\" \"${config.networking.hostName} is going offline\"";
      };
    };

    "ntfy-failure@" = {
      description = "Notify on service failure for %i";
      serviceConfig.Type = "oneshot";
      scriptArgs = "%i";
      script = ''
        logs="$(${lib.getExe' pkgs.systemd "journalctl"} --unit "$1" --lines 5 --reverse --no-pager --boot | ${lib.getExe' pkgs.coreutils "head"} -c 4095)"
        ${lib.getExe config.rebuild.notify} "Service $1 failed" "warning" "max" "$logs"
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    2586 # ntfy-sh
  ];

  networking.nftables = {
    enable = true;
    tables.excludeFromVPN = {
      family = "inet";
      content = ''
        chain excludeOutgoing {
          type route hook output priority -10; policy accept;
          # ssh
          tcp sport 22 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # smb
          tcp dport { 137, 139, 445 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          tcp sport { 137, 139, 445 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          udp dport { 137, 138 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          udp sport { 137, 138 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # ntfy, syncthing
          tcp dport { 2586, 8384, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          udp dport { 21027, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        }
      '';
    };
  };

  rebuild.owner = "dashalev";

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
      files = [
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          mode = "0600";
        }
        "/etc/ssh/ssh_host_ed25519_key.pub"
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          mode = "0600";
        }
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };

  fileSystems = {
    "/".neededForBoot = true;
    "/entertainment" = {
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
