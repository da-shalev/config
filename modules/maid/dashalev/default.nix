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

  user_dirs = {
    XDG_DOCUMENTS_DIR = lib.mkDefault "$HOME/media/dox";
    XDG_MUSIC_DIR = lib.mkDefault "$HOME/media/mus";
    XDG_VIDEOS_DIR = lib.mkDefault "$HOME/media/vid";
    XDG_PICTURES_DIR = lib.mkDefault "$HOME/media/pix";
    XDG_DOWNLOAD_DIR = lib.mkDefault "$HOME/media/dow";
    XDG_PUBLICSHARE_DIR = lib.mkDefault "$HOME/media/projects";

    XDG_DESKTOP_DIR = lib.mkDefault "$HOME/";
    XDG_TEMPLATES_DIR = lib.mkDefault "$HOME/";
  };

  # XDG compliance
  file.xdg_config = {
    "git/ignore".source = ./git/ignore;
    "git/config".source = ./git/config;
    "mpd/mpd.conf".source = ./mpd.conf;
    "rmpc/config.ron".source = ./rmpc/config.ron;
    "rmpc/themes".source = ./rmpc/themes;
    "mimeapps.list".source = ./mimeapps.list;
    "fnott/fnott.ini".text = ''
      ${builtins.readFile ./fnott/fnott.ini}
      play-sound=${lib.getExe' pkgs.pipewire "pw-play"} ''${filename}

      [critical]
      border-color=fb4934ff
      sound-file=${./fnott/critical.flac}

      [normal]
      border-color=b16286FF
      sound-file=${./fnott/info.flac}

      [low]
      border-color=b16286FF
    '';
    "foot/foot.ini".source = ./foot.ini;
    "lsd/config.yaml".source = ./lsd.yaml;
    "tms/config.toml".source = ./tms.toml;
    "mpv/mpv.conf".source = ./mpv.conf;
    "fd/ignore".source = ./fd/ignore;
    # "looking-glass/client.ini".source = ./looking-glass/client.ini;
    "hypr/hypridle.conf".source = ./hypridle.conf;
  };

  dirs = [ "$XDG_STATE_HOME/bash" ];
  shell = {
    package = lib.mkDefault pkgs.fish;
    aliases = {
      s = "${lib.getExe pkgs.lsd} -lA";
    };

    variables = {
      # JAVA_HOME = "${lib.getExe' pkgs.jdk21 "java"}";
      JAVA_HOME = "${pkgs.jdk21}";
      JDK21 = pkgs.jdk21;
      JDK17 = pkgs.jdk17;
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
  };

  packages =
    with pkgs;
    [
      lsd
      tmux-sessionizer
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
      dysk
      bat
      hyperfine

      bun
      nodejs
      nimble

      ffmpeg
      yt-dlp
      wget

      unzip
      p7zip
      zip
      rar
      unrar

      asciiquarium-transparent
      cmatrix
      nyancat
      sl

      # music stuff
      spek
      # shntool
      # beets
      # python313Packages.audiotools
      # eyed3
      flac
      rmpc
      (pkgs.makeDesktopItem {
        name = "rmpc";
        desktopName = "rmpc";
        exec = "rmpc";
        terminal = true;
        categories = [ "System" ];
        comment = "TUI client for MPD ";
        icon = "org.gnome.Music";
      })
      cava

      neovim
      treefmt
      openssl
      gh
      mdwatch

      # custom
      fzf-media
      fzf-search
    ]
    ++ lib.optionals config.hyprland.enable [
      vicinae
      mpv
      nautilus
      foot
      code-cursor
      claude-code

      obs-studio
      localsend
      signal-desktop-bin
      vulkan-hdr-layer-kwin6

      qbittorrent
      pcsx2
      # nomachine-client
      nicotine-plus

      (wrappers.wrapWith pkgs {
        basePackage = nur.repos.forkprince.helium-nightly;
        prependFlags = [
          # FIX: broken blacks in chrome for now
          "--disable-features=WaylandWpColorManagerV1"
        ];
      })
      firefox-beta

      # blender
      prismlauncher
      tutanota-desktop
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
    ];

    config = ''
      ${builtins.readFile ./hyprland.conf}
    '';
  };

  tmux = {
    enable = true;
    config = ''
      ${builtins.readFile ./tmux.conf}
    '';
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

    interactive = ''
      ${builtins.readFile ./fish/config.fish}
    '';
  };

  vicinae = {
    favorites = [
      "applications:helium"
      "applications:org.gnome.Nautilus"
      "applications:rmpc"
      "applications:tutanota-desktop"
      "applications:signal"
      "applications:system.upgrade"
      "applications:system.bootgrade"
      "applications:system.update"
      "applications:system.cleanup"
      "applications:system.optimise"
    ];
    settings = builtins.fromJSON (builtins.readFile ./vicinae/settings.json);
  };
}
