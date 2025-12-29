{ lib, ... }:
{
  systemd.targets = lib.genAttrs [ "sleep" "suspend" "hibernate" "hybrid-sleep" ] (_: {
    enable = lib.mkForce false;
  });
}
