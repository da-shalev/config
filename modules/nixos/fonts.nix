{ pkgs, ... }:
{
  console = {
    packages = with pkgs; [ spleen ];
    font = "spleen-16x32";
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      corefonts
      iosevka
      inter
      nerd-fonts.symbols-only
      twitter-color-emoji
      fraunces
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Fraunces"
          "Symbols Nerd Font"
        ];
        sansSerif = [
          "Inter Variable"
          "Symbols Nerd Font"
        ];
        monospace = [
          "Iosevka"
          "Symbols Nerd Font Mono"
        ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
