lib:
let
  sources = import ../npins;

  overlayAuto =
    final: prev:
    (
      builtins.readDir ./.
      |> lib.filterAttrs (_: value: value == "directory")
      |> lib.mapAttrs (name: _: final.callPackage ./${name} { })
    );

  overlayMisc = final: prev: {
    nix = prev.nix;
    stable = (import sources.nixpkgs-stable) {
      inherit (final) system;
      config = {
        allowUnfree = true;
      };
    };
    nur = (import sources.NUR) {
      pkgs = prev;
    };
    wrappers = (import sources.wrapper-manager).lib;
    neovim = (import sources.mnw).lib.wrap final { imports = [ ./neovim/module.nix ]; };
    maid = (import sources.nix-maid) final ../modules/maid;
  };
in

lib.composeManyExtensions [
  overlayAuto
  overlayMisc
]
