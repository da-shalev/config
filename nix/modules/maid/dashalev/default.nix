{
  pkgs,
  config,
  lib,
  ...
}:
{
  dconf.settings = {
    "/org/gnome/desktop/interface/color-scheme" = "prefer-dark";
    "/org/gnome/desktop/wm/preferences/button-layout" = "";
  };

  wayland = {
    cursor_theme = {
      name = "macOS";
      package = pkgs.apple-cursor;
    };
    icon_theme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
  };

  xdg = {
    dirs = {
      enable = true;
      documents = "$HOME/media/dox";
      music = "$HOME/media/mus";
      videos = "$HOME/media/vid";
      pictures = "$HOME/media/pix";
      download = "$HOME/media/dow";
      public_share = "$HOME/media/pub";
      projects = "$HOME/media/projects";
      desktop = "$HOME";
      templates = "$HOME";
    };

    defaults =
      let
        browser = "helium.desktop";
        image = "imv.desktop";
        video = "mpv.desktop";
      in
      {
        terminal = "footclient.desktop";
        mime = {
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/chrome" = browser;
          "text/html" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/xhtml+xml" = browser;
          "application/x-extension-xhtml" = browser;
          "application/x-extension-xht" = browser;
          "x-scheme-handler/sgnl" = "signal.desktop";
          "x-scheme-handler/signalcaptcha" = "signal.desktop";
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "image/png" = image;
          "image/jpeg" = image;
          "image/gif" = image;
          "image/bmp" = image;
          "image/tiff" = image;
          "image/webp" = image;
          "image/x-icon" = image;
          "image/svg+xml" = image;
          "video/mp4" = video;
          "video/x-msvideo" = video;
          "video/quicktime" = video;
          "video/x-matroska" = video;
          "video/webm" = video;
          "video/ogg" = video;
          "video/mpeg" = video;
          "video/x-flv" = video;
          "video/3gpp" = video;
          "video/x-ms-wmv" = video;
        };
      };
  };

  dirs = [ "{{xdg_state_home}}/bash" ];

  file.xdg_config = {
    "git/ignore".source = ./git/ignore;
    "git/config".source = ./git/config;
    "mpd/mpd.conf".source = ./mpd.conf;
    "rmpc/config.ron".source = ./rmpc/config.ron;
    "rmpc/themes".source = ./rmpc/themes;
    "fnott/fnott.ini".text = ''
      ${builtins.readFile ./fnott/fnott.ini}
      play-sound=${lib.getExe' pkgs.pipewire "pw-play"} ''${filename}

      [critical]
      border-color=fb4934ff
      sound-file=${./sfx/critical.flac}

      [normal]
      border-color=b16286FF
      sound-file=${./sfx/info.flac}

      [low]
      border-color=b16286FF
    '';
    "foot/foot.ini".source = ./foot.ini;
    "lsd/config.yaml".source = ./lsd.yaml;
    "tms/config.toml".source = ./tms.toml;
    "mpv/mpv.conf".source = ./mpv.conf;
    "obs-studio/basic/profiles/max-quality/recordEncoder.json".source = ./obs/max-quality.json;
    "fd/ignore".source = ./fd/ignore;
    "hypr/hypridle.conf".source = ./hypridle.conf;
  };

  shell.aliases = {
    s = "${lib.getExe pkgs.lsd} -lA";
  };

  variables = {
    JAVA_HOME = "${pkgs.jdk21}";
    MOZ_CRASHREPORTER_DISABLE = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    EDITOR = "nvim";
    QT_SCALE_FACTOR = 1.5;
    FZF_DEFAULT_OPTS = ''
      --height=100%
      --layout=reverse
      --bind 'ctrl-o:execute(test -f {1} && xdg-open {1})+accept'
      --bind 'ctrl-e:execute(nvim {1})+abort'
    '';
  };

  packages =
    with pkgs;
    [
      lsd

      tmux-sessionizer
      nur.repos.jeffguorg.claude-code-bin
      # nur.repos.aster-void.claude-code-usage-monitor
      opencode

      pulsemixer
      bluetuith

      woff2
      ripgrep
      jq
      yq
      fd
      npins
      usbutils
      pciutils
      file
      libva-utils
      exiftool
      clang-tools
      rsync
      tree
      vimv
      onefetch
      fastfetch
      btop
      htop
      nvitop
      dysk
      bat
      hyperfine

      bun
      nodejs
      nimble
      devenv

      ffmpeg
      yt-dlp
      wget
      unzip
      p7zip
      zip
      rar

      asciiquarium-transparent
      cmatrix
      nyancat
      sl

      # music stuff
      rmpc
      (lib.hiPrio (
        pkgs.makeDesktopItem {
          name = "rmpc";
          desktopName = "rmpc";
          exec = lib.getExe pkgs.rmpc;
          terminal = true;
          categories = [
            "AudioVideo"
            "Audio"
            "Player"
            "Music"
            "ConsoleOnly"
          ];
          comment = "Rusty Music Player Client";
          icon = "multimedia-player";
        }
      ))
      cava

      neovim
      treefmt
      nixfmt
      stylua
      ruff
      openssl
      gh
      railway
      mdwatch

      # custom
      fzf-media
      fzf-search
    ]
    ++ lib.optionals config.hyprland.enable [
      mpv
      nautilus
      sushi
      nur.repos.forkprince.helium-nightly
      localsend
    ];

  hyprland = {
    packages = with pkgs; [
      foot
      fnott
      mpd
      vicinae
      hyprshot
      hyprsunset
      hyprpicker
      wl-clipboard
      mpc
      hypridle
    ];

    config = ./hyprland/main.lua;

    extra_configs = {
      "binds.lua" = ./hyprland/binds.lua;
      "master.lua" = ./hyprland/master.lua;
      "scrolling.lua" = ./hyprland/scrolling.lua;
    };

    start = [
      "foot --server --log-no-syslog"
      "fnott"
      "mpd"
      "vicinae server --no-extension-runtime"
      "hypridle"
    ];
  };

  tmux = {
    enable = true;
    config = ./tmux.conf;
    plugins = with pkgs.tmuxPlugins; [ yank ];
  };

  fish = {
    enable = true;
    themes = [
      {
        name = "fishsticks";
        source = ./fish/fishsticks.theme;
      }
    ];

    plugins = with pkgs.fishPlugins; [
      puffer
      autopair
    ];

    interactive = ./fish/config.fish;
  };

  vicinae = {
    favorites = [
      "applications:helium"
      "applications:org.gnome.Nautilus"
      "applications:rmpc"
      "applications:signal"
      "applications:system.upgrade"
      "applications:system.bootgrade"
      "applications:system.update"
      "applications:system.cleanup"
      "applications:system.optimise"
    ];
    theme = {
      dark = "rose-pine";
      light = "rose-pine-dawn";
    };
    settings = {
      close_on_focus_loss = true;
      launcher_window = {
        opacity = 1.0;
        blur.enabled = false;
      };
      providers = {
        applications.enabled = true;
        "browser-extension".enabled = false;
        clipboard.preferences.monitoring = true;
        core.enabled = false;
        developer.enabled = false;
        "manage-shortcuts".enabled = false;
        power.entrypoints = {
          hibernate.enabled = false;
          lock.enabled = false;
          sleep.enabled = false;
          "soft-reboot".enabled = false;
          suspend.enabled = false;
        };
        "raycast-compat".enabled = false;
        shortcuts.enabled = false;
        theme.enabled = false;
      };
    };
  };

}
