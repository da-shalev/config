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
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };

    idleConfig = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };

    extraConfig = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };

    packages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf config.hyprland.enable {
    packages = config.hyprland.packages;
    file.xdg_config."hypr/hypridle.conf".source = config.hyprland.idleConfig;
    file.xdg_config."hypr/hyprland.conf".text = ''
      $mod=${config.hyprland.mod}
      ${builtins.readFile config.hyprland.config}
      ${builtins.readFile config.hyprland.extraConfig}
    '';
  };
}
