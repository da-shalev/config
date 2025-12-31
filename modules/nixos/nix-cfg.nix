{ pkgs, ... }:
{
  environment.etc.nixpkgs.source = pkgs.path;

  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=/etc/nixpkgs" ];
    settings = {
      builders-use-substitutes = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
        "fetch-closure"
        "dynamic-derivations"
        "pipe-operators"
      ];
      use-cgroups = true;
      auto-allocate-uids = true;
      warn-dirty = false;
    };

    registry.nixpkgs.to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = (import ../../npins).nixpkgs.revision;
    };
  };
}
