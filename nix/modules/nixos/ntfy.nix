{
  lib,
  config,
  ...
}:
let
  cfg = config.services.ntfy;
in
{
  options.services.ntfy = {
    enable = lib.mkEnableOption "ntfy-sh push notifications";

    port = lib.mkOption {
      type = lib.types.port;
      default = 2586;
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://${config.networking.hostName}:${toString cfg.port}";
        listen-http = "0.0.0.0:${toString cfg.port}";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
