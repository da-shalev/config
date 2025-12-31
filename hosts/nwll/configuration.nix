{ lib, ... }:
{
  security.sudo.wheelNeedsPassword = false;
  networking.firewall.enable = false;

  programs = {
    nix-ld.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    gnupg.agent.enable = true;
    localsend.enable = true;
    git.enable = true;
    direnv = {
      enable = true;
      silent = true;
    };

    command-not-found.enable = false;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    fstrim.enable = true;
    udisks2.enable = true;
    dbus.implementation = "broker";
    openssh.enable = true;
    rsyncd.enable = true;
    speechd.enable = lib.mkForce false;
  };

  time.timeZone = "Canada/Eastern";
  system.stateVersion = "26.05";
}
