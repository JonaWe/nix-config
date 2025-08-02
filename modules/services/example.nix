{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.example;
in {
  options.myconf.services.example = {
    enable = lib.mkEnableOption "Enable example service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9999;
      example = 9999;
      description = "Opens ports for example service";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/example";
      description = "Directory used for example service";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.example = {
      enable = true;
      port = cfg.port;
    };

    services.nginx.virtualHosts."example.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/example" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 example example -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/example".useTemplate = ["default"];
      };
    };
  };
}
