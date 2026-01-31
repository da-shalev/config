lib:
let
  sources = import ../npins;
  hyprland =
    (import sources.flake-compat {
      src = sources.Hyprland;
    }).defaultNix;

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
      nurpkgs = prev;
      pkgs = prev;
    };

    fetchGithubRelease =
      url: tag:
      let
        release = builtins.fromJSON (
          builtins.readFile (builtins.fetchurl "https://api.github.com/repos/${url}/releases/${tag}")
        );
      in
      builtins.fetchurl (builtins.head release.assets).browser_download_url;

    # use vicinae directly sourced from git
    vicinae = (import sources.vicinae { pkgs = final; }).vicinae;
    wrappers = (import sources.wrapper-manager).lib;
    neovim = (import sources.mnw).lib.wrap final { imports = [ ./neovim/module.nix ]; };
    maid = (import sources.nix-maid) final ../modules/maid;
    hyprland = hyprland.packages.${final.stdenv.hostPlatform.system}.default;
    xdg-desktop-portal-hyprland =
      hyprland.packages.${final.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
in

lib.composeManyExtensions [
  overlayAuto
  overlayMisc
]
