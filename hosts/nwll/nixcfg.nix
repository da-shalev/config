{
  pkgs,
  inputs,
  ...
}:
{
  nix = {
    package = pkgs.nixVersions.latest;
    registry.nixpkgs.flake = inputs.nixpkgs;
    channel.enable = false;
    settings = {
      nix-path = "nixpkgs=flake:nixpkgs";
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
  };
}
