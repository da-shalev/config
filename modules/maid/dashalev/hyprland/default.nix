{
  pkgs,
  lib,
  ...
}:
{
  hyprland.config = ''
    ${builtins.readFile ./hyprland.conf}

    exec-once=${lib.getExe pkgs.foot} --server --log-no-syslog
    exec-once=${lib.getExe pkgs.fnott}
    exec-once=${lib.getExe pkgs.mpd}

    bind=$mod, Return, exec, ${lib.getExe' pkgs.foot "footclient"} -D ~/media
    bind=$mod+Shift, S, exec, ${lib.getExe pkgs.hyprshot} -m region --clipboard-only
    bind=$mod+Shift, N, exec, pkill hyprsunset || ${lib.getExe pkgs.hyprsunset} -t 4000
    bind=$mod+Shift, C, exec, pkill hyprpicker || ${lib.getExe pkgs.hyprpicker} | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}
    bind=$mod, Space, exec, pkill wmenu || ${lib.getExe' pkgs.da.wmenu "wmenu-run"}
    bind=$mod, Z, exec, ${lib.getExe pkgs.da.bookmark-paste}

    bind = , XF86AudioPlay, exec, ${lib.getExe pkgs.mpc} toggle
    bind = , XF86AudioPrev, exec, ${lib.getExe pkgs.mpc} prev
    bind = , XF86AudioNext, exec, ${lib.getExe pkgs.mpc} next
  '';
}
