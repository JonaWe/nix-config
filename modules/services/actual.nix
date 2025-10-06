{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.actual;
in {
  options.myconf.services.actual = {
    enable = lib.mkEnableOption "Enable actual service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9284;
      example = 9284;
      description = "Port that is used for actual";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/actual-server";
      example = "/var/lib/actual-server";
      description = "Base directory that is used to store actual-server data";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."actual-server" = {
      image = "docker.io/actualbudget/actual-server:latest";
      # environment = {
      #   "TZ" = "Europe/Berlin";
      # };
      ports = [
        "127.0.0.1:${toString cfg.port}:5006"
      ];
      volumes = [
        "${cfg.dataDir}:/data:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."actual.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/actual" = {
        type = "zfs_fs";
        mountpoint = cfg.dataDir;
        options.mountpoint = "legacy";
      };
    };

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/actual".useTemplate = ["default"];
      };
    };
  };
}
