let
  pkgs = import ../packages;
  sources = import ../npins;
in
modules:
pkgs.nixos (
  [
    ../modules/nixos/overlays.nix
    ../modules/nixos/nix-cfg.nix
    (import "${sources.preservation}/module.nix")
    (import "${sources.disko}/module.nix")
    (import sources.nix-maid).nixosModules.default
  ]
  ++ modules
)
