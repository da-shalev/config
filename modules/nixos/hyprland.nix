{
  pkgs,
  ...
}:
# adds newest hyprland module sourced directly via npins
let
  sources = import ../../npins;
  hyprland =
    (import sources.flake-compat {
      src = sources.Hyprland;
    }).defaultNix;
in
{
  imports = [
    hyprland.nixosModules.default
  ];

  programs.hyprland = {
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # yea these don't work currently

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  nix.settings = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };
}
