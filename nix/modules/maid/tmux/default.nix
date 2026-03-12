{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.tmux = {
    enable = lib.mkEnableOption "Enable tmux." // {
      default = false;
    };

    plugins = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
    };

    config = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (p: "${p}") lib.types.str;
    };
  };

  config = lib.mkIf config.tmux.enable {
    packages = with pkgs; [ tmux ];
    file.xdg_config =
      let
        plugins = builtins.concatStringsSep "\n" (
          map (
            plugin: "run-shell ${plugin}/share/tmux-plugins/${plugin.pluginName}/${plugin.pluginName}.tmux"
          ) config.tmux.plugins
        );
      in
      {
        "tmux/tmux.conf".text = ''
          ${builtins.readFile config.tmux.config}
          ${plugins}
        '';
      };
  };
}
