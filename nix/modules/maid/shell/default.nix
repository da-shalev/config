{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    shell = {
      color = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };

      icon = lib.mkOption {
        type = lib.types.nonEmptyStr;
      };

      source_env = lib.mkOption {
        type = lib.types.package;
        default = pkgs.writeShellScriptBin "source-env" ''
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: ''export ${name}="${builtins.toString value}"'') config.variables
          )}
        '';
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of paths to prepend to PATH";
      };

      aliases = lib.mkOption {
        type = with lib.types; attrsOf (with lib.types; str);
        default = { };
        description = "Local user defined aliases.";
      };
    };

    variables = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      description = "Per-user session environment variables.";
    };

    dirs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "List of non-standard directories to create for tools that don't fully follow the XDG specification, like Wine.";
    };
  };

  config = {
    packages = [ config.shell.source_env ];

    variables = {
      SHELL_COLOR = "${config.shell.color}";
      SHELL_ICON = "${config.shell.icon}";
      PATH = lib.concatStringsSep ":" (config.shell.paths ++ [ "$PATH" ]);
    };

    systemd.tmpfiles.dynamicRules = map (p: "d ${p} 0755 {{user}} {{group}} - -") config.dirs;
  };
}
