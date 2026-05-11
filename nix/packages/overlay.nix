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
      nurpkgs = prev;
      pkgs = prev;
    };

    fetchGithubRelease =
      url: tag: asset:
      let
        endpoint =
          if tag == "latest" then
            "https://api.github.com/repos/${url}/releases/latest"
          else
            "https://api.github.com/repos/${url}/releases/tags/${tag}";
        release = builtins.fromJSON (builtins.readFile (builtins.fetchurl endpoint));
        matching = builtins.filter (a: a.name == asset) release.assets;
      in
      builtins.fetchurl (builtins.head matching).browser_download_url;

    wrappers = (import sources.wrapper-manager).lib;
    neovim = (import sources.mnw).lib.wrap final { imports = [ ./neovim/module.nix ]; };
    maid = (import sources.nix-maid) final ../modules/maid;

    inherit
      (((import sources.flake-compat) { src = sources.Hyprland; }).defaultNix.packages.${final.system})
      hyprland
      xdg-desktop-portal-hyprland
      ;
  };
in

lib.composeManyExtensions [
  overlayAuto
  overlayMisc
]
