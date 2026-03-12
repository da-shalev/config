{ lib, config, ... }:
let
  cfg = config.services.convex;
in
{
  options.services.convex = {
    enable = lib.mkEnableOption "Convex self-hosted backend";

    backendPort = lib.mkOption {
      type = lib.types.port;
      default = 3210;
    };

    sitePort = lib.mkOption {
      type = lib.types.port;
      default = 3211;
    };

    dashboardPort = lib.mkOption {
      type = lib.types.port;
      default = 6791;
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    preservation.preserveAt."/nix/persist".directories = [
      { directory = "/var/lib/containers"; }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.backendPort
      cfg.sitePort
      cfg.dashboardPort
    ];

    virtualisation.oci-containers.containers = {
      convex-backend = {
        image = "ghcr.io/get-convex/convex-backend:latest";
        ports = [
          "127.0.0.1:${toString cfg.backendPort}:3210"
          "127.0.0.1:${toString cfg.sitePort}:3211"
        ];
        volumes = [ "convex-data:/convex/data" ];
        environment = {
          CONVEX_CLOUD_ORIGIN = "http://127.0.0.1:${toString cfg.backendPort}";
          CONVEX_SITE_ORIGIN = "http://127.0.0.1:${toString cfg.sitePort}";
          RUST_LOG = "info";
          DISABLE_METRICS_ENDPOINT = "true";
          DOCUMENT_RETENTION_DELAY = "172800";
          APPLICATION_MAX_CONCURRENT_MUTATIONS = "16";
          APPLICATION_MAX_CONCURRENT_NODE_ACTIONS = "16";
          APPLICATION_MAX_CONCURRENT_QUERIES = "16";
          APPLICATION_MAX_CONCURRENT_V8_ACTIONS = "16";
        };
        extraOptions = [
          "--stop-signal=SIGINT"
          "--stop-timeout=10"
          "--health-cmd=curl -f http://localhost:3210/version"
          "--health-interval=5s"
          "--health-start-period=10s"
        ];
      };

      convex-dashboard = {
        image = "ghcr.io/get-convex/convex-dashboard:latest";
        ports = [ "127.0.0.1:${toString cfg.dashboardPort}:6791" ];
        environment = {
          NEXT_PUBLIC_DEPLOYMENT_URL = "http://127.0.0.1:${toString cfg.backendPort}";
        };
        dependsOn = [ "convex-backend" ];
        extraOptions = [
          "--stop-signal=SIGINT"
          "--stop-timeout=10"
        ];
      };
    };
  };
}
