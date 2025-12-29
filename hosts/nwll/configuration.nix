{
  security.sudo.wheelNeedsPassword = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      25565
      53317
      4321
      8096
      8097
      2234
      8888
      5173
    ];

    allowedUDPPorts = [
      53317
    ];
  };

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
    gvfs.enable = true;
    fstrim.enable = true;
    udisks2.enable = true;
    dbus.implementation = "broker";
    openssh.enable = true;
    rsyncd.enable = true;
  };

  time.timeZone = "Canada/Eastern";
  system.stateVersion = "26.05";
}
