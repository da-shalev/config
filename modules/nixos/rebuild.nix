{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.rebuild = {
    dir = lib.mkOption {
      type = lib.types.str;
      default = "/config";
    };

    path = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = "${config.rebuild.dir}";
    };

    owner = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = {
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
        rebuildPath = config.rebuild.path;
        hostPath = "hosts/${config.networking.hostName}";

        upgrade = pkgs.writeShellApplication {
          name = "upgrade";
          runtimeInputs = with pkgs; [
            libnotify
            nixos-rebuild
          ];
          text = ''
            [ "$TERM" != "linux" ] && notify-send -a "System" "Upgrade started" -u normal
            SECONDS=0

            if sudo nixos-rebuild switch --file ${rebuildPath}/${hostPath}; then
              [ "$TERM" != "linux" ] && notify-send -a "System" "Upgrade complete" "Finished in $SECONDS seconds" -u normal
            else
              [ "$TERM" != "linux" ] && notify-send -a "System" "Upgrade failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };

        update = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            libnotify
            nix
          ];
          text = ''
            [ "$TERM" != "linux" ] && notify-send -a "System" "Update started" -u normal
            SECONDS=0
            if ${lib.getExe pkgs.npins} --lock-file ${rebuildPath}/npins/sources.json update; then
              [ "$TERM" != "linux" ] && notify-send -a "System" "Update complete" "Finished in $SECONDS seconds" -u normal
            else
              [ "$TERM" != "linux" ] && notify-send -a "System" "Update failed" "Failed after $SECONDS seconds" -u critical
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
            [ "$TERM" != "linux" ] && notify-send -a "System" "Bootgrade started" -u normal
            SECONDS=0
            if sudo nixos-rebuild boot --file ${rebuildPath}/${hostPath}; then
              [ "$TERM" != "linux" ] && notify-send -a "System" "Bootgrade complete" "Finished in $SECONDS seconds" -u normal
            else
              [ "$TERM" != "linux" ] && notify-send -a "System" "Bootgrade failed" "Failed after $SECONDS seconds" -u critical
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
            [ "$TERM" != "linux" ] && notify-send -a "System" "Cleanup started" -u normal
            SECONDS=0
            if sudo nix-collect-garbage -d; then
              [ "$TERM" != "linux" ] && notify-send -a "System" "Cleanup complete" "Finished in $SECONDS seconds" -u normal
            else
              [ "$TERM" != "linux" ] && notify-send -a "System" "Cleanup failed" "Failed after $SECONDS seconds" -u critical
            fi
          '';
        };
      in
      {
        variables.NIXPKGS_CONFIG = lib.mkOverride 0 config.rebuild.path;
        systemPackages = [
          upgrade
          update
          bootgrade
          cleanup

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
            name = "system.upgrade";
            desktopName = "Upgrade";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe upgrade}";
            terminal = false;
            categories = [ "System" ];
            comment = "Build latest system";
            icon = "software-update-available-symbolic";
          })

          (pkgs.makeDesktopItem {
            name = "system.update";
            desktopName = "Update";
            exec = "${lib.getExe' pkgs.systemd "systemd-run"} --user ${lib.getExe update}";
            terminal = false;
            categories = [ "System" ];
            comment = "Fetch latest sources";
            icon = "view-refresh-symbolic";
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
        ];
      };
  };
}
