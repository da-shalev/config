let
  sources = import ../npins;
  lib = import "${sources.nixpkgs}/lib";
  nixpkgsConfiguration = {
    allowUnfree = true;
  };
in
import sources.nixpkgs {
  config = nixpkgsConfiguration;

  overlays = [
    (import ./overlay.nix lib nixpkgsConfiguration)
  ];
}
