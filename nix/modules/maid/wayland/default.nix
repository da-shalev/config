{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.wayland = {
    enable = lib.mkEnableOption "Yep" // {
      default = false;
    };

    cursor_theme = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Adwaita";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = pkgs.adwaita-icon-theme;
      };
      size = lib.mkOption {
        type = lib.types.number;
        default = 24;
      };
    };

    icon_theme = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Adwaita";
      };
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = pkgs.adwaita-icon-theme;
      };
    };

    theme = {
      name = lib.mkOption {
        type = with lib.types; nonEmptyStr;
        default = "adw-gtk3-dark";
      };

      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = pkgs.adw-gtk3;
      };
    };
  };

  config = lib.mkIf config.wayland.enable {
    file = {
      xdg_data = lib.mkMerge [
        (lib.mkIf (config.wayland.cursor_theme.package != null) {
          "icons/${config.wayland.cursor_theme.name}".source =
            "${config.wayland.cursor_theme.package}/share/icons/${config.wayland.cursor_theme.name}";
        })
        (lib.mkIf (config.wayland.icon_theme.package != null) {
          "icons/${config.wayland.icon_theme.name}".source =
            "${config.wayland.icon_theme.package}/share/icons/${config.wayland.icon_theme.name}";
        })
        (lib.mkIf (config.wayland.theme.package != null) {
          "themes/${config.wayland.theme.name}".source =
            "${config.wayland.theme.package}/share/themes/${config.wayland.theme.name}";
        })
      ];

      xdg_config = {
        "gtk-3.0/settings.ini".text =
          let
            settings = [
              "[Settings]"
              (lib.optionalString (
                config.wayland.cursor_theme.package != null
              ) "gtk-cursor-theme-name=${config.wayland.cursor_theme.name}")
              (lib.optionalString (
                config.wayland.cursor_theme.package != null
              ) "gtk-cursor-theme-size=${toString config.wayland.cursor_theme.size}")
              (lib.optionalString (
                config.wayland.icon_theme.package != null
              ) "gtk-icon-theme-name=${config.wayland.icon_theme.name}")
              (lib.optionalString (
                config.wayland.theme.package != null
              ) "gtk-theme-name=${config.wayland.theme.name}")
              "gtk-recent-files-enabled=false"
            ];
          in
          lib.concatStringsSep "\n" (lib.filter (s: s != "") settings);
        "gtk-4.0/settings.ini".text =
          let
            settings = [
              "[Settings]"
              (lib.optionalString (
                config.wayland.cursor_theme.package != null
              ) "gtk-cursor-theme-name=${config.wayland.cursor_theme.name}")
              (lib.optionalString (
                config.wayland.cursor_theme.package != null
              ) "gtk-cursor-theme-size=${toString config.wayland.cursor_theme.size}")
              (lib.optionalString (
                config.wayland.icon_theme.package != null
              ) "gtk-icon-theme-name=${config.wayland.icon_theme.name}")
              (lib.optionalString (
                config.wayland.theme.package != null
              ) "gtk-theme-name=${config.wayland.theme.name}")
              "gtk-recent-files-enabled=false"
            ];
          in
          lib.concatStringsSep "\n" (lib.filter (s: s != "") settings);
      };
    };

    variables = {
      MOZ_ENABLE_WAYLAND = 1;
      PROTON_ENABLE_WAYLAND = 1;
      DXVK_HDR = 1;
      NIXOS_OZONE_WL = 1;
      ENABLE_HDR_WSI = 1;
      SDL_VIDEODRIVER = "wayland";
    }
    // lib.optionalAttrs (config.wayland.cursor_theme.package != null) {
      XCURSOR_THEME = config.wayland.cursor_theme.name;
      XCURSOR_SIZE = "${toString config.wayland.cursor_theme.size}";
      XCURSOR_PATH = "${config.xdg.home.data}/icons";
    };

    dconf.settings = lib.mkMerge [
      (lib.optionalAttrs (config.wayland.icon_theme.package != null) {
        "/org/gnome/desktop/interface/icon-theme" = config.wayland.icon_theme.name;
      })
      (lib.optionalAttrs (config.wayland.cursor_theme.package != null) {
        "/org/gnome/desktop/interface/cursor-theme" = config.wayland.cursor_theme.name;
        "/org/gnome/desktop/interface/cursor-size" = config.wayland.cursor_theme.size;
      })
      (lib.optionalAttrs (config.wayland.theme.package != null) {
        "/org/gnome/desktop/interface/gtk-theme" = config.wayland.theme.name;
      })
    ];

    packages = with pkgs; [
      wl-clipboard
      libnotify
      xeyes
      imv
      libxcvt
    ];
  };
}
