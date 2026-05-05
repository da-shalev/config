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
      default = "/config";
    };

    owner = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    notify = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

  };

  config = {
    rebuild.notify = pkgs.writeShellApplication {
      name = "notify-phone";
      runtimeInputs = with pkgs; [ curl ];
      text = ''
        curl -fso /dev/null \
          -H "Title: $1" \
          -H "Tags: $2" \
          -H "Priority: ''${3:-high}" \
          -d "''${4:-}" \
          http://localhost:${toString config.services.ntfy.port}/${config.networking.hostName}
      '';
    };

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
            notify-phone "Upgrade started" "arrow_up" "default" "Building system configuration"
            SECONDS=0

            if sudo nixos-rebuild switch --file ${rebuildPath}/${hostPath}; then
              # workaround: https://github.com/viperML/nix-maid/issues/59
              systemctl --user restart maid-activation.service || true
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Upgrade complete" "Finished in $SECONDS seconds" -u normal
              notify-phone "Upgrade complete" "white_check_mark" "default" "Finished in $SECONDS seconds"
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Upgrade failed" "Failed after $SECONDS seconds" -u critical
              notify-phone "Upgrade failed" "x" "high" "Failed after $SECONDS seconds"
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
            notify-phone "Update started" "arrow_up" "default" "Fetching latest sources"
            SECONDS=0
            if cd ${rebuildPath} && npins update; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Update complete" "Finished in $SECONDS seconds" -u normal
              notify-phone "Update complete" "white_check_mark" "default" "Finished in $SECONDS seconds"
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Update failed" "Failed after $SECONDS seconds" -u critical
              notify-phone "Update failed" "x" "high" "Failed after $SECONDS seconds"
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
            notify-phone "Bootgrade started" "arrow_up" "default" "Building next boot generation"
            SECONDS=0
            if sudo nixos-rebuild boot --file ${rebuildPath}/${hostPath}; then
              # workaround: https://github.com/viperML/nix-maid/issues/59
              systemctl --user restart maid-activation.service || true
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Bootgrade complete" "Finished in $SECONDS seconds" -u normal
              notify-phone "Bootgrade complete" "white_check_mark" "default" "Finished in $SECONDS seconds"
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Bootgrade failed" "Failed after $SECONDS seconds" -u critical
              notify-phone "Bootgrade failed" "x" "high" "Failed after $SECONDS seconds"
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
            notify-phone "Cleanup started" "arrow_up" "default" "Collecting garbage"
            SECONDS=0
            if sudo nix-collect-garbage -d; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Cleanup complete" "Finished in $SECONDS seconds" -u normal
              notify-phone "Cleanup complete" "white_check_mark" "default" "Finished in $SECONDS seconds"
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Cleanup failed" "Failed after $SECONDS seconds" -u critical
              notify-phone "Cleanup failed" "x" "high" "Failed after $SECONDS seconds"
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
            notify-phone "Optimization started" "arrow_up" "default" "Deduplicating nix store"
            SECONDS=0
            if nix store optimise; then
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Optimization complete" "Finished in $SECONDS seconds" -u normal
              notify-phone "Optimization complete" "white_check_mark" "default" "Finished in $SECONDS seconds"
            else
              [ -n "''${WAYLAND_DISPLAY:-}" ] && notify-send -a "System" "Optimization failed" "Failed after $SECONDS seconds" -u critical
              notify-phone "Optimization failed" "x" "high" "Failed after $SECONDS seconds"
            fi
          '';
        };
      in
      {
        systemPackages = [
          config.rebuild.notify
          upgrade
          update
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
