{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    ghostty.terminfo
  ];
  security.sudo.wheelNeedsPassword = false;
  networking.firewall.enable = false;

  programs = {
    hyprland.enable = true;
    nix-ld.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    gnupg.agent.enable = true;
    git.enable = true;
    direnv = {
      enable = true;
      silent = true;
      nix-direnv = {
        enable = true;
      };
    };

    command-not-found.enable = false;
  };

  services = {
    gvfs.enable = true;
    fstrim.enable = true;
    udisks2.enable = true;
    dbus.implementation = "broker";
    openssh.enable = true;
    rsyncd.enable = true;
    speechd.enable = lib.mkForce false;
  };

  time.timeZone = (builtins.fromJSON (builtins.readFile ./user.json)).timezone;
}
