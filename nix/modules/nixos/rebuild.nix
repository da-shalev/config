{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.rebuild = {
    path = lib.mkOption {
      type = lib.types.path;
      default = "/nix/config";
    };

    owner = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    bundleConfig = lib.mkEnableOption "bundle the config into the build";
  };

  config = {
    system.activationScripts.bundleConfig = lib.mkIf config.rebuild.bundleConfig (
      let
        src = lib.fileset.toSource {
          root = ./../../..;
          fileset = lib.fileset.unions [
            (lib.fileset.gitTracked ./../../..)
            ./../../../.git
          ];
        };
        chownLine = lib.optionalString (config.rebuild.owner != null) ''
          ${lib.getExe' pkgs.coreutils "chown"} -R ${config.rebuild.owner}:users ${config.rebuild.path}
        '';
      in
      {
        deps = [ "users" ];
        text = ''
          ${lib.getExe' pkgs.coreutils "mkdir"} -p ${config.rebuild.path}
          ${lib.getExe' pkgs.coreutils "cp"} -rT --no-preserve=ownership ${src} ${config.rebuild.path}
          ${lib.getExe' pkgs.coreutils "chmod"} -R u+w ${config.rebuild.path}
          ${chownLine}
        '';
      }
    );

    preservation.preserveAt."/nix/persist" = {
      directories = [
        (
          {
            directory = config.rebuild.path;
          }
          // lib.optionalAttrs (config.rebuild.owner != null) {
            user = config.rebuild.owner;
            group = "users";
          }
        )
      ];
    };

    environment =
      let
        rebuildPath = "${config.rebuild.path}/nix";
        hostPath = "hosts/${config.networking.hostName}";

        upgrade = pkgs.writeShellApplication {
          name = "upgrade";
          runtimeInputs = with pkgs; [
            libnotify
            nixos-rebuild
          ];
          text = ''
            [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Upgrade started" -u normal
            SECONDS=0

            if sudo nixos-rebuild switch --file ${rebuildPath}/${hostPath}; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Upgrade complete" "Finished in $SECONDS seconds" -u normal
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Upgrade failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        update = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            libnotify
            npins
          ];
          text = ''
            [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Update started" -u normal
            SECONDS=0
            if cd ${rebuildPath} && npins update; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Update complete" "Finished in $SECONDS seconds" -u normal
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Update failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        bootgrade = pkgs.writeShellApplication {
          name = "bootgrade";
          runtimeInputs = with pkgs; [
            libnotify
            nixos-rebuild
          ];
          text = ''
            [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Bootgrade started" -u normal
            SECONDS=0
            if sudo nixos-rebuild boot --file ${rebuildPath}/${hostPath}; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Bootgrade complete" "Finished in $SECONDS seconds" -u normal
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Bootgrade failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        cleanup = pkgs.writeShellApplication {
          name = "cleanup";
          runtimeInputs = with pkgs; [
            libnotify
            nix
          ];
          text = ''
            [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Cleanup started" -u normal
            SECONDS=0
            if sudo nix-collect-garbage -d; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Cleanup complete" "Finished in $SECONDS seconds" -u normal
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Cleanup failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        optimise = pkgs.writeShellApplication {
          name = "optimise";
          runtimeInputs = with pkgs; [
            libnotify
            nix
          ];
          text = ''
            [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Optimization started" -u normal
            SECONDS=0
            if nix store optimise; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Optimization complete" "Finished in $SECONDS seconds" -u normal
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Optimization failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        config-install = pkgs.writeShellApplication {
          name = "config-install";
          runtimeInputs = [ pkgs.nixos-install-tools ];
          text = ''
            if [ "$#" -lt 1 ]; then
              echo "usage: config-install <host-path>" >&2
              exit 1
            fi
            sudo nixos-install -f "$1"
          '';
        };

        ssh-install = pkgs.writeShellApplication {
          name = "ssh-install";
          runtimeInputs = [
            pkgs.age
            pkgs.coreutils
            config.programs.ssh.package
          ];
          text = ''
            if [ "$#" -ne 1 ]; then
              echo "usage: ssh-install <key.age>" >&2
              exit 1
            fi

            src="$1"
            dst="$HOME/.ssh/id_ed25519"
            pub="$dst.pub"
            tmp="$(mktemp "$HOME/.ssh/.id_ed25519.XXXXXX")"

            cleanup() {
              rm -f "$tmp"
            }
            trap cleanup EXIT

            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"

            age -d "$src" > "$tmp"
            chmod 600 "$tmp"
            mv -f "$tmp" "$dst"
            ssh-keygen -y -f "$dst" > "$pub"
            trap - EXIT
          '';
        };
      in
      {
        systemPackages = [
          ssh-install
          update

          (pkgs.makeDesktopItem {
            name = "system.update";
            desktopName = "Update";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe update}";
            terminal = false;
            categories = [ "System" ];
            comment = "Fetch latest sources";
            icon = "view-refresh-symbolic";
          })
        ]
        ++ lib.optionals config.rebuild.bundleConfig [
          config-install
        ]
        ++ lib.optionals (!config.rebuild.bundleConfig) [
          upgrade
          bootgrade
          cleanup
          optimise

          (pkgs.makeDesktopItem {
            name = "system.upgrade";
            desktopName = "Upgrade";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe upgrade}";
            terminal = false;
            categories = [ "System" ];
            comment = "Build latest system";
            icon = "software-update-available-symbolic";
          })

          (pkgs.makeDesktopItem {
            name = "system.bootgrade";
            desktopName = "Bootgrade";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe bootgrade}";
            terminal = false;
            categories = [ "System" ];
            comment = "Build new boot generation";
            icon = "system-reboot-symbolic";
          })

          (pkgs.makeDesktopItem {
            name = "system.cleanup";
            desktopName = "Cleanup";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe cleanup}";
            terminal = false;
            categories = [ "System" ];
            comment = "Clean up system garbage";
            icon = "user-trash-full";
          })

          (pkgs.makeDesktopItem {
            name = "system.optimise";
            desktopName = "Optimise";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe optimise}";
            terminal = false;
            categories = [ "System" ];
            comment = "Deduplicates the store";
            icon = "user-trash-full";
          })
        ];
      };
  };
}
