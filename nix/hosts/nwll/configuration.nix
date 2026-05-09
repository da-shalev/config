{ lib, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.ghostty.terminfo ];
  security.sudo.wheelNeedsPassword = false;
  networking.firewall.enable = false;
  # services.flatpak.enable = true;

  programs = {
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

  # virtualisation.docker.enable = false;
  services = {
    # mongodb.enable = true;
    gvfs.enable = true;
    fstrim.enable = true;
    udisks2.enable = true;
    dbus.implementation = "broker";
    openssh.enable = true;
    rsyncd.enable = true;
    speechd.enable = lib.mkForce false;
  };

  time.timeZone = (builtins.fromJSON (builtins.readFile ./user.json)).timezone;
  # nix.settings = {
  #   sandbox = "relaxed";
  #   extra-sandbox-paths = [
  #     "/dev/nvidia0"
  #     "/dev/nvidiactl"
  #     "/dev/nvidia-modeset"
  #     "/dev/nvidia-uvm"
  #     "/dev/nvidia-uvm-tools"
  #     "/run/opengl-driver"
  #   ];
  # };

  system.stateVersion = "26.05";
}
