let
  pkgs = import ../packages;
  sources = import ../npins;
in
hostName: modules:
pkgs.nixos (
  [
    {
      networking = { inherit hostName; };
    }
    ../modules/nixos/overlays.nix
    ../modules/nixos/nix-cfg.nix
    ../modules/nixos/rebuild.nix
    (import "${sources.preservation}/module.nix")
    (import "${sources.disko}/module.nix")
    (import sources.nix-maid).nixosModules.default
  ]
  ++ modules
)
