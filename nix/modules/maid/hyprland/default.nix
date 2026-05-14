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

    extra_configs = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.coercedTo lib.types.path builtins.readFile lib.types.lines);
      description = "Extra lua files placed at ~/.config/hypr/<key>, e.g. require()-able modules.";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    packages = config.hyprland.packages;
    file.xdg_config = {
      "hypr/hyprland.lua".text = ''
        ${lib.optionalString (config.hyprland.start != [ ]) ''
          hl.on('hyprland.start', function()
          ${lib.concatMapStringsSep "\n" (cmd: "  hl.exec_cmd([[exec ${cmd}]])") config.hyprland.start}
          end)
        ''}
        ${config.hyprland.config}
      '';
    } // lib.mapAttrs' (name: txt: lib.nameValuePair "hypr/${name}" { text = txt; }) config.hyprland.extra_configs;
  };
}
