{
  lib,
  config,
  pkgs,
  modules,
  ...
}:
let
  read =
    m:
    let
      v = import m;
    in
    if lib.isFunction v then
      v {
        inherit
          lib
          config
          pkgs
          modules
          ;
      }
    else
      v;
  localModules = lib.filter builtins.isPath modules;
  maidUsers = lib.filter (u: u ? maid) (
    lib.concatMap (m: lib.attrValues ((read m).users.users or { })) localModules
  );
  maidUses =
    name:
    lib.any (
      u:
      (u.maid.${name}.enable or false)
      || lib.any (m: (read m).${name}.enable or false) (u.maid.imports or [ ])
    ) maidUsers;

  shellInit = ''
    [ -r "${config.system.build.all-maid}/nix-maid-$USER/bin/source-env" ] && . "${config.system.build.all-maid}/nix-maid-$USER/bin/source-env"
  '';
in
{
  maid.sharedModules = [
    ../maid/shell
    ../maid/xdg
    ../maid/wayland
    ../maid/tmux
    ../maid/fish
    ../maid/hyprland
    ../maid/vicinae
  ];

  systemd.user.services.maid-activation = {
    script = lib.mkBefore shellInit;
    after = lib.mkForce [
      "systemd-tmpfiles-setup.service"
    ];
    before = [ "basic.target" ];
    requiredBy = [ "basic.target" ];
    unitConfig.DefaultDependencies = false;
  };

  systemd.user.services.maid-gsettings = {
    wantedBy = [ "default.target" ];
    after = [ "maid-activation.service" ];
    requires = [ "dconf.service" ];
    serviceConfig.ExecStart = lib.getExe' pkgs.coreutils "true";
  };

  environment.shellInit = lib.mkBefore shellInit;

  programs = {
    fish.enable = lib.mkOverride 0 (maidUses "fish");
    hyprland.enable = lib.mkOverride 0 (maidUses "hyprland");
  };
}
