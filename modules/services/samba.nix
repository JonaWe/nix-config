{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.samba;
in {
  options.myconf.services.samba = {
    enable = lib.mkEnableOption "Enable samba file sharing";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for samba services";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "samba-data";
      description = "User used for samba service";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "samba-data";
      description = "Group used for samba service";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = {};

    services.samba = {
      openFirewall = cfg.openFirewall;
      enable = true;
      settings = {
        global = {
          "server string" = "Nix Samba Share";
          "netbios name" = "smbnix";
          security = "user";
          "hosts allow" = "100.64.0. 127.0.0.1 localhost";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        winkelsheim = {
          path = "/data/samba/winkelsheim";
          "read only" = "no";
          browsable = "yes";
          writable = "yes";
          "guest ok" = "yes";
          "create mask" = 0644;
          "directory mask" = 0755;
          "force user" = cfg.user;
          comment = "public samba share";
        };
        games = {
          path = "/data/samba/games";
          "read only" = "no";
          browsable = "yes";
          writable = "yes";
          "guest ok" = "yes";
          "create mask" = 0644;
          "directory mask" = 0755;
          "force user" = cfg.user;
          comment = "Game Library";
        };
        jona = {
          path = "/data/samba/jona";
          "read only" = "no";
          browsable = "yes";
          writable = "yes";
          "guest ok" = "yes";
          "create mask" = 0644;
          "directory mask" = 0755;
          "force user" = cfg.user;
          comment = "jona samba share";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/samba" = {
        type = "zfs_fs";
        options.mountpoint = "none";
      };
      "enc/services/samba/winkelsheim" = {
        type = "zfs_fs";
        mountpoint = "/data/samba/winkelsheim";
        options.mountpoint = "legacy";
        options.quota = "500G";
        options.recordsize = "1M";
      };
      "enc/services/samba/jona" = {
        type = "zfs_fs";
        mountpoint = "/data/samba/jona";
        options.mountpoint = "legacy";
        options.quota = "500G";
        options.recordsize = "1M";
      };
      "enc/services/samba/games" = {
        type = "zfs_fs";
        mountpoint = "/data/samba/games";
        options.mountpoint = "legacy";
        options.quota = "2T";
        options.recordsize = "16K";
      };
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.zfsIntegration.enable [
      "d /data/samba/winkelsheim 0700 ${cfg.user} ${cfg.group} -"
      "d /data/samba/jona 0700 ${cfg.user} ${cfg.group} -"
      "d /data/samba/games 0700 ${cfg.user} ${cfg.group} -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/samba/winkelsheim".useTemplate = ["default"];
        "zdata/enc/services/samba/jona".useTemplate = ["default"];
      };
    };
  };
}
