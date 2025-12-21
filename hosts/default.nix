let
  pkgs = import ../packages;
  sources = import ../npins;
in
modules:
pkgs.nixos (
  [
    (import "${sources.preservation}/module.nix")
    ./preservation.nix
  ]
  ++ modules
)
