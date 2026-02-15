{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.monitoring;
in {
  options.myconf.services.monitoring = {
    enable = lib.mkEnableOption "Enable monitoring service";
    grafanaPort = lib.mkOption {
      type = lib.types.port;
      default = 3031;
      example = 3031;
      description = "Ports for grafana service";
    };
    # directory = lib.mkOption {
    #   type = lib.types.str;
    #   default = "/var/lib/example";
    #   description = "Directory used for example service";
    # };
    # zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    # zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "albatross";
          static_configs = [
            {targets = ["100.64.0.9:9100"];}
          ];
        }
      ];
      listenAddress = "0.0.0.0";
    };

    services.grafana = {
      enable = true;
      settings.server = {
        http_addr = "0.0.0.0";
        http_port = cfg.grafanaPort;
      };
    };

    networking.firewall.allowedTCPPorts = [9090];

    services.nginx.virtualHosts."grafana.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.grafanaPort}";
      };
    };

    # myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
    #   "enc/services/example" = {
    #     type = "zfs_fs";
    #     mountpoint = cfg.directory;
    #     options.mountpoint = "legacy";
    #   };
    # };
    #
    # systemd.tmpfiles.rules = [
    #   "d ${cfg.directory} 0700 example example -"
    # ];
    #
    # services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
    #   datasets = {
    #     "zdata/enc/services/example".useTemplate = ["default"];
    #   };
    # };
  };
}
