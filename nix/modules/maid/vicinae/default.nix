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
      type = lib.types.submodule {
        options = {
          dark = lib.mkOption {
            type = lib.types.str;
            default = "vicinae-dark";
          };
          light = lib.mkOption {
            type = lib.types.str;
            default = "vicinae-light";
          };
        };
      };
      default = { };
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
      lib.recursiveUpdate
        (
          {
            theme = lib.recursiveUpdate {
              dark.name = config.vicinae.theme.dark;
              light.name = config.vicinae.theme.light;
            } (
              lib.optionalAttrs (config.wayland.icon_theme.package != null) {
                dark.icon_theme = config.wayland.icon_theme.name;
                light.icon_theme = config.wayland.icon_theme.name;
              }
            );
          }
          // lib.optionalAttrs (config.vicinae.favorites != [ ]) {
            favorites = config.vicinae.favorites;
          }
        )
        config.vicinae.settings
    );
  };
}
