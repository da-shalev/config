{
  config,
  lib,
  ...
}:
{
  options.hyprland = {
    enable = lib.mkEnableOption "Configures hyprland." // {
      default = false;
    };

    idleConfig = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };

    config = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };

    extraConfig = lib.mkOption {
      type = lib.types.nullOr (lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str);
      default = null;
    };

    packages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf config.hyprland.enable {
    packages = config.hyprland.packages;
    file.xdg_config."hypr/hypridle.conf".source = config.hyprland.idleConfig;
    file.xdg_config."hypr/hyprland.lua".text = ''
      ${builtins.readFile config.hyprland.config}
      ${lib.optionalString (config.hyprland.extraConfig != null) (
        builtins.readFile config.hyprland.extraConfig
      )}
    '';
  };
}
