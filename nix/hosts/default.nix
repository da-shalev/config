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
    (import sources.nix-maid).nixosModules.default
    (import "${sources.preservation}/module.nix")
    (import "${sources.disko}/module.nix")
    ../modules/nixos/maid.nix
    ../modules/nixos/overlays.nix
    ../modules/nixos/nix-cfg.nix
    ../modules/nixos/rebuild.nix
  ]
  ++ modules
)
