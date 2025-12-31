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
      fraunces
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      (pkgs.runCommand "apple-emoji-linux" { } ''
        mkdir -p $out/share/fonts/truetype
        cp ${pkgs.fetchGithubRelease "samuelngs/apple-emoji-linux" "latest"} $out/share/fonts/truetype/AppleColorEmoji.ttf
      '')
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
        emoji = [ "Apple Color Emoji" ];
      };
    };
  };
}
