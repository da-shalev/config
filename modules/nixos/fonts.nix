{ pkgs, lib, ... }:
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
      nerd-fonts.symbols-only
      source-han-sans
      source-han-serif

      (pkgs.runCommand "apple-emoji-linux" { } ''
        mkdir -p $out/share/fonts/truetype
        cp ${pkgs.fetchGithubRelease "samuelngs/apple-emoji-linux" "latest"} $out/share/fonts/truetype/AppleColorEmoji.ttf
      '')
    ];

    fontconfig = {
      enable = true;
      hinting = {
        enable = lib.mkDefault false;
        style = lib.mkDefault "none"; # yes this makes a difference even when hinting.enable = false;
      };
      subpixel = {
        lcdfilter = lib.mkDefault "none";
        rgba = lib.mkDefault "none";
      };
      defaultFonts = {
        serif = [
          "Source Han Serif"
          "Symbols Nerd Font"
        ];
        sansSerif = [
          "Source Han Sans"
          "Symbols Nerd Font"
        ];
        monospace = [
          "Iosevka"
          "Symbols Nerd Font Mono"
        ];
        emoji = [ "Apple Color Emoji" ];
      };
    };
  };
}
