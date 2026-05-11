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

    config = lib.mkOption {
      type = lib.types.coercedTo lib.types.path builtins.readFile lib.types.lines;
    };

    packages = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };

    start = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = "Commands appended to hyprland.start (exec-once semantics).";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    packages = config.hyprland.packages;
    file.xdg_config."hypr/hyprland.lua".text = ''
      ${lib.optionalString (config.hyprland.start != [ ]) ''
        hl.on('hyprland.start', function()
        ${lib.concatMapStringsSep "\n" (cmd: "  hl.exec_cmd([[exec ${cmd}]])") config.hyprland.start}
        end)
      ''}
      ${config.hyprland.config}
    '';
  };
}
