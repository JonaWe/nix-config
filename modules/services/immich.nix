{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.immich;
in {
  options.myconf.services.immich = {
    enable = lib.mkEnableOption "Enable immich service for photo management";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for immich service";
    };
    mediaDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/data/media/immich";
      description = "Directory used for photo storage";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    users.users.immich = {
      isSystemUser = true;
      group = "immich";
      extraGroups = ["video" "render"];
    };
    users.groups.immich = {};

    services.immich = {
      enable = true;
      openFirewall = cfg.openFirewall;
      host = "127.0.0.1";
      port = 2283;
      mediaLocation = cfg.mediaDirectory;
      user = "immich";
      group = "immich";
      # settings.server.externalDomain = "https://immich.home.pinkorca.de";
      # environment = {
      #   IMMICH_ENV = "production";
      #   IMMICH_LOG_LEVEL = "log";
      # };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/immich" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/immich";
        options.mountpoint = "legacy";
      };
      "enc/services/immich/media" = {
        type = "zfs_fs";
        mountpoint = cfg.mediaDirectory;
        options.mountpoint = "legacy";
        options.quota = "2T";
        options.recordsize = "1M";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mediaDirectory} 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/immich".useTemplate = ["default"];
        "zdata/enc/services/immich/media".useTemplate = ["default"];
      };
    };

    services.nginx.virtualHosts."immich.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      extraConfig = ''
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
        client_max_body_size 50000M;
      '';
      locations."/" = {
        proxyPass = "http://${toString config.services.immich.host}:${toString config.services.immich.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
