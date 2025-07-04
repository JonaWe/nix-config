{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.seafile;
in {
  options.myconf.services.seafile = {
    enable = lib.mkEnableOption "Enable seafile filesharing server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5238;
      example = 5238;
      description = "Port used for seafile";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for seafile service";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/data/seafile";
      example = "/var/lib/seafile";
      description = "Directory used seafile storage";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.seafile = {
      enable = true;
      # dataDir = cfg.directory;
      adminEmail = "jona@pinkorca.de";
      initialAdminPassword = "password";
      ccnetSettings = {
        General = {
          SERVICE_URL = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/seafile" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
    };

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/seafile".useTemplate = ["default"];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 seafile seafile -"
    ];

    services.nginx.virtualHosts."seafile.ts.pinkorca.de" = {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}/";
      };
    };
  };
}
