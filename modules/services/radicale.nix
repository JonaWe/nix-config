{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.radicale;
in {
  options.myconf.services.radicale = {
    enable = lib.mkEnableOption "Enable radicale caldav server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5232;
      example = 5232;
      description = "Port used for radicale";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for immich service";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/data/radicale";
      example = "/var/lib/radicale";
      description = "Directory used radicale calender storage";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = ["127.0.0.1:${toString cfg.port}"];
        };
        storage = {
          filesystem_folder = "${cfg.directory}/collections";
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "${cfg.directory}/users";
          htpasswd_encryption = "bcrypt";
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/radicale" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
    };

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/radicale".useTemplate = ["default"];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 radicale radicale -"
      "d ${cfg.directory}/collections 0700 radicale radicale -"
    ];

    services.nginx.virtualHosts."cal.ts.pinkorca.de" = {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      };
    };
  };
}
