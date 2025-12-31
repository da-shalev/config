{
  lib,
  config,
  ...
}:
{
  options.vicinae = {
    enable = lib.mkEnableOption "Yep" // {
      default = config.hyprland.enable;
    };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "vicinae-dark";
    };
    favorites = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional JSON settings";
    };
  };

  config = lib.mkIf config.vicinae.enable {
    file.xdg_config."vicinae/settings.json".text = builtins.toJSON (
      {
        theme = {
          dark = {
            theme = config.vicinae.theme;
          }
          // lib.optionalAttrs (config.wayland.icon_theme.package != null) {
            icon_theme = config.wayland.icon_theme.name;
          };
        };
      }
      // lib.optionalAttrs (config.vicinae.favorites != [ ]) {
        favorites = config.vicinae.favorites;
      }
      // config.vicinae.settings
    );
  };
}
