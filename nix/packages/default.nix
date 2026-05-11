let
  sources = import ../npins;
  lib = import "${sources.nixpkgs}/lib";
in
import sources.nixpkgs {
  config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  overlays = [
    (import ./overlay.nix lib)
  ];
}
