let
  sources = import ../../npins;
in
(import ../. "vm" [
  "${sources.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ../../modules/nixos/audio.nix
  ../../modules/nixos/fonts.nix
  ../../modules/nixos/common.nix
  ./configuration.nix
]).config.system.build.vm
