let
  sources = import ../../npins;
in
(import ../. "qiso" [
  "${sources.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ../../modules/nixos/audio.nix
  ../../modules/nixos/fonts.nix
  ../../modules/nixos/common.nix
  ./configuration.nix
  ./hardware.nix
]).config.system.build.isoImage
