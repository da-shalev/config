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

    mod = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
    };

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    packages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf config.hyprland.enable {
    packages = config.hyprland.packages;
    file.xdg_config."hypr/hyprland.conf".text = ''
      $mod=${config.hyprland.mod}
      ${config.hyprland.config}
      ${config.hyprland.extraConfig}
    '';
  };
}
