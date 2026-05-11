{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
        pkgs.dwproton-bin
      ];
      package = pkgs.steam.override {
        extraPkgs = pkgs': with pkgs'; [ libpulseaudio ];
      };
    };
    hyprland.enable = true;
    # ydotool = {
    #   enable = true;
    #   group = "input";
    # };
  };

  services = {
    # syncthing = {
    #   enable = true;
    #   user = "dashalev";
    #   dataDir = config.users.users.dashalev.home;
    #   openDefaultPorts = true;
    #   settings = {
    #     devices."android".id = "N5EM67F-W5T7BEE-XW747IA-U55OJIM-UFZ2C3M-ECGV52P-QQXCHL7-ETODIQ6";
    #     devices."macbook".id = "66CZCNP-VXJD72V-7CVQ3OH-66KYE46-REWGZ3X-VNVLPSA-GKSBBDP-7L66EAP";
    #     folders."music" = {
    #       path = "${config.users.users.dashalev.home}/media/mus";
    #       label = "Music";
    #       type = "sendonly";
    #       devices = [
    #         "android"
    #         "macbook"
    #       ];
    #       ignorePatterns = [ ".thumbnails" ];
    #     };
    #     folders."documents" = {
    #       path = "${config.users.users.dashalev.home}/media/dox";
    #       label = "Documents";
    #       devices = [
    #         "android"
    #         "macbook"
    #       ];
    #     };
    #   };
    # };

    # samba = {
    #   enable = true;
    #   openFirewall = true;
    #   nmbd.enable = true;
    #   settings = {
    #     global = {
    #       security = "user";
    #       "map to guest" = "Bad Password";
    #       "socket options" = "TCP_NODELAY";
    #       "use sendfile" = "yes";
    #     };
    #     entertainment = {
    #       path = "/entertainment";
    #       "guest ok" = "yes";
    #       "guest only" = "yes";
    #       "read only" = "yes";
    #       browseable = "yes";
    #     };
    #   };
    # };

    # ntfy = {
    #   enable = true;
    #   openFirewall = true;
    # };

    # smartd = {
    #   enable = true;
    #   notifications = {
    #     wall.enable = false;
    #     test = false;
    #   };
    #   defaults.monitored = "-a -m root -M exec ${pkgs.writeShellScript "smartd-notify" ''
    #     ${lib.getExe config.rebuild.notify} "Disk health warning" "warning" "max" "$SMARTD_MESSAGE"
    #   ''}";
    # };

    mullvad-vpn = {
      enable = true;
      package = pkgs.stable.mullvad;
    };

  };

  # power.ups = {
  #   enable = true;
  #   mode = "standalone";
  #   ups.cyberpower = {
  #     driver = "usbhid-ups";
  #     port = "auto";
  #   };
  #   upsmon = {
  #     monitor.cyberpower = {
  #       system = "cyberpower@localhost";
  #       powerValue = 1;
  #       user = "upsmon";
  #     };
  #     settings = {
  #       NOTIFYCMD = "p=high; case $NOTIFYTYPE in LOWBATT|FSD) p=max;; esac; ${lib.getExe config.rebuild.notify} 'UPS: '$NOTIFYTYPE 'electric_plug' $p 'Power event: '$NOTIFYTYPE";
  #       NOTIFYFLAG = [
  #         [
  #           "ONLINE"
  #           "SYSLOG+EXEC"
  #         ]
  #         [
  #           "ONBATT"
  #           "SYSLOG+EXEC"
  #         ]
  #         [
  #           "LOWBATT"
  #           "SYSLOG+EXEC"
  #         ]
  #         [
  #           "REPLBATT"
  #           "SYSLOG+EXEC"
  #         ]
  #         [
  #           "FSD"
  #           "SYSLOG+EXEC"
  #         ]
  #       ];
  #     };
  #   };
  #   users.upsmon = {
  #     passwordFile = "/dev/null";
  #     upsmon = "primary";
  #   };
  # };

  # security.pam.services.sshd.rules.session.ntfy-notify = {
  #   order = 12300;
  #   control = "optional";
  #   modulePath = "pam_exec.so";
  #   args = [
  #     "seteuid"
  #     "${pkgs.writeShellScript "ssh-notify" ''
  #       if [ "$PAM_TYPE" = "open_session" ]; then
  #         ${lib.getExe config.rebuild.notify} "SSH login" "rotating_light" "high" "$PAM_USER from ''${PAM_RHOST:-local}"
  #       fi
  #     ''}"
  #   ];
  # };

  systemd.services = {
    upsdrv.serviceConfig.SuccessExitStatus = "1";

    # ntfy-boot = {
    #   description = "Notify on system startup";
    #   wants = [ "network-online.target" ];
    #   after = [
    #     "network-online.target"
    #     "multi-user.target"
    #     "ntfy-sh.service"
    #   ];
    #   requires = [ "ntfy-sh.service" ];
    #   wantedBy = [ "multi-user.target" ];
    #   restartIfChanged = false;
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     ExecStart = "${lib.getExe config.rebuild.notify} \"System started\" \"green_circle\" \"default\" \"${config.networking.hostName} is online\"";
    #   };
    # };
    #
    # ntfy-shutdown = {
    #   description = "Notify on system shutdown";
    #   after = [ "ntfy-sh.service" ];
    #   requires = [ "ntfy-sh.service" ];
    #   wantedBy = [ "multi-user.target" ];
    #   restartIfChanged = false;
    #   serviceConfig = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     ExecStart = "${lib.getExe' pkgs.coreutils "true"}";
    #     ExecStop = "${lib.getExe config.rebuild.notify} \"System shutting down\" \"red_circle\" \"high\" \"${config.networking.hostName} is going offline\"";
    #   };
    # };
    #
    # "ntfy-failure@" = {
    #   description = "Notify on service failure for %i";
    #   serviceConfig.Type = "oneshot";
    #   scriptArgs = "%i";
    #   script = ''
    #     logs="$(${lib.getExe' pkgs.systemd "journalctl"} --unit "$1" --lines 5 --reverse --no-pager --boot | ${lib.getExe' pkgs.coreutils "head"} -c 4095)"
    #     ${lib.getExe config.rebuild.notify} "Service $1 failed" "warning" "max" "$logs"
    #   '';
    # };
  };

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
          # tcp dport { 137, 139, 445 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # tcp sport { 137, 139, 445 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # udp dport { 137, 138 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # udp sport { 137, 138 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # ntfy, syncthing, radicale
          # tcp dport { 2586, 5232, 8384, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # tcp sport { 2586, 5232, 8384, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # udp dport { 21027, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # udp sport { 21027, 22000 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # web dev
          tcp dport 3000-3005 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          tcp sport 3000-3005 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          # localsend
          tcp dport 53317 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          tcp sport 53317 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          udp dport 53317 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          udp sport 53317 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        }
      '';
    };
  };

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
      uid = 1000;
      extraGroups = [
        "wheel"
        "video"
        "networkmanager"
        "kvm"
        "input"
        "docker"
        "audio"
      ];
      shell = pkgs.fishMinimal;
      initialPassword = "boobs";

      maid = {
        imports = [ ../../modules/maid/dashalev ];

        shell = {
          color = "magenta";
          icon = "🗿";
        };

        hyprland = {
          enable = true;
          config = lib.mkAfter ./hyprland.lua;
        };

        wayland = {
          enable = true;
          cursor_theme.size = 40;
        };

        packages = with pkgs; [
          zed-editor
          obs-studio
          localsend
          signal-desktop
          telegram-desktop
          vulkan-hdr-layer-kwin6

          qbittorrent
          nicotine-plus
          firefox

          dolphin-emu

          # blender
          # prismlauncher
          # postman
          # azahar
        ];
      };
    };
  };
}
