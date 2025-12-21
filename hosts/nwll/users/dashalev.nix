{ pkgs, ... }:
{
  imports = [ ../modules/maid/dashalev ];

  file.xdg_config = {
    "looking-glass/client.ini".source = ./looking-glass/client.ini;
  };

  shell = {
    package = pkgs.fish;
    colour = "magenta";
    icon = "🗿";
  };

  hyprland = {
    enable = true;
    extraConfig = ''
      monitor=DP-1,highres@highrr,auto,1
      env=GSK_RENDERER,ngl
    '';
  };

  wayland = {
    enable = true;
    cursor_theme.size = 40;
  };
}
