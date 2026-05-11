{
  lib,
  config,
  ...
}:
let
  cfg = config.xdg;

  baseDirs = {
    data = {
      env = "XDG_DATA_HOME";
      default = "$HOME/.local/share";
      description = "Base directory for user-specific data files.";
    };
    state = {
      env = "XDG_STATE_HOME";
      default = "$HOME/.local/state";
      description = "Base directory for user-specific state data.";
    };
    config = {
      env = "XDG_CONFIG_HOME";
      default = "$HOME/.config";
      description = "Base directory for user-specific configuration files.";
    };
    cache = {
      env = "XDG_CACHE_HOME";
      default = "$HOME/.cache";
      description = "Base directory for user-specific non-essential (cached) data.";
    };
  };

  userDirs = {
    desktop = {
      env = "XDG_DESKTOP_DIR";
      description = "The desktop directory.";
    };
    documents = {
      env = "XDG_DOCUMENTS_DIR";
      description = "The documents directory.";
    };
    download = {
      env = "XDG_DOWNLOAD_DIR";
      description = "The download directory.";
    };
    music = {
      env = "XDG_MUSIC_DIR";
      description = "The music directory.";
    };
    pictures = {
      env = "XDG_PICTURES_DIR";
      description = "The pictures directory.";
    };
    projects = {
      env = "XDG_PROJECTS_DIR";
      description = "The projects directory.";
    };
    public_share = {
      env = "XDG_PUBLICSHARE_DIR";
      description = "The public share directory.";
    };
    templates = {
      env = "XDG_TEMPLATES_DIR";
      description = "The templates directory.";
    };
    videos = {
      env = "XDG_VIDEOS_DIR";
      description = "The videos directory.";
    };
  };

  resolvedBase = lib.mapAttrs' (n: spec: lib.nameValuePair spec.env cfg.home.${n}) baseDirs;
  resolvedUser =
    (lib.mapAttrs' (n: spec: lib.nameValuePair spec.env cfg.dirs.${n}) (
      lib.filterAttrs (n: _: cfg.dirs.${n} != null) userDirs
    ))
    // cfg.dirs.extra_config;

  toList = v: if lib.isList v then v else [ v ];

  terminals = toList cfg.defaults.terminal;

  mimeAssocs =
    lib.optionalAttrs (terminals != [ ]) {
      "x-scheme-handler/terminal" = terminals;
    }
    // cfg.defaults.mime;

  renderMime =
    assocs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "${k}=${lib.concatMapStringsSep ";" (x: x) (toList v)};") assocs
    );
in
{
  options.xdg = {
    home = lib.mapAttrs (
      _: spec:
      lib.mkOption {
        type = lib.types.str;
        inherit (spec) default description;
      }
    ) baseDirs;

    dirs = {
      enable = lib.mkEnableOption "XDG user directories" // {
        default = true;
      };

      extra_config = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Non-standard XDG user dirs.";
      };
    }
    // lib.mapAttrs (
      _: spec:
      lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        inherit (spec) description;
      }
    ) userDirs;

    defaults = {
      terminal = lib.mkOption {
        type = with lib.types; either str (listOf str);
        default = [ ];
        description = ''
          Preferred terminal emulator(s) as `.desktop` file names.
          First entry is primary; later entries are fallbacks.
          Populates `xdg-terminals.list` (xdg-terminal-exec spec) and
          the `x-scheme-handler/terminal` association in `mimeapps.list`.
        '';
      };

      mime = lib.mkOption {
        type = with lib.types; attrsOf (either str (listOf str));
        default = { };
        description = ''
          MIME type → `.desktop` file associations written to
          `mimeapps.list` under `[Default Applications]`.
        '';
      };
    };
  };

  config = lib.mkMerge [
    { variables = resolvedBase; }

    (lib.mkIf cfg.dirs.enable {
      variables = resolvedUser;

      file.xdg_config = {
        "user-dirs.conf".text = ''
          enabled=False
        '';

        "user-dirs.dirs".text = ''
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''${k}="${v}"'') resolvedUser)}
        '';
      };

      systemd.tmpfiles.dynamicRules = lib.mapAttrsToList (
        _: v: "d ${lib.replaceStrings [ "$HOME" ] [ "{{home}}" ] v} 0755 {{user}} {{group}} - -"
      ) resolvedUser;
    })

    (lib.mkIf (terminals != [ ]) {
      file.xdg_config."xdg-terminals.list".text = lib.concatLines terminals;
    })

    (lib.mkIf (mimeAssocs != { }) {
      file.xdg_config."mimeapps.list".text = ''
        [Default Applications]
        ${renderMime mimeAssocs}
      '';
    })
  ];
}
