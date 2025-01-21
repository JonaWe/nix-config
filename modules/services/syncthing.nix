{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.syncthing;
in {
  options.myconf.services.syncthing = {
    enable = lib.mkEnableOption "Enable Syncthing to share files between devices";
    user = lib.mkOption {
      type = lib.types.str;
      default = "syncthing";
      description = "User that is used for syncthing. When using the default user the user is created otherwise you have to create the user yourself";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "syncthing";
      description = "Group that is used for syncthing";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "Location for the data base directory";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.dataDir}/.config/syncthing";
      description = "Location for the configuration directory";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."syncthing/devices/${config.networking.hostName}/key" = {
      owner = cfg.user;
      group = cfg.group;
    };
    sops.secrets."syncthing/devices/${config.networking.hostName}/cert" = {
      owner = cfg.user;
      group = cfg.group;
    };
    services.syncthing = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;
      overrideDevices = true;
      overrideFolders = true;
      key = config.sops.secrets."syncthing/devices/${config.networking.hostName}/key".path;
      cert = config.sops.secrets."syncthing/devices/${config.networking.hostName}/cert".path;
      settings = let
        devices = {
          pangolin = {
            id = "SCRTM6K-4YE5FGZ-HP27RDE-Z4PUUNQ-WUVCGF6-633QWR5-X6XYMPS-V72OFQB";
          };
          phone = {
            id = "NWDFWNP-J265KD5-TG6JSA6-5VWRPIN-PN3IBIW-2TUWQ2D-WCKAZ3Q-ZGQ7LAN";
          };
          homelab = {
            id = "DP6G2PA-QLRCJRJ-SZ644M2-LVX2T47-33KGVYT-2QJXS7N-JFXGNZ5-IIVC5Q5";
          };
        };
        device-names = builtins.attrNames devices;
      in {
        devices = devices;
        folders = {
          "keepass" = {
            id = "keepass";
            label = "Keepass Database";
            path = "${cfg.dataDir}/.keepass";
            devices = device-names;
          };
          "vault" = {
            id = "vault";
            label = "Obsidian Vault";
            path = "${cfg.dataDir}/vault";
            devices = device-names;
          };
          "wallpapers" = {
            id = "wallpapers";
            label = "Wallpapers";
            path = "${cfg.dataDir}/pictures/wallpapers";
            devices = device-names;
          };
          "android-camera" = {
            id = "android-camera";
            label = "Android Camera";
            path = "${cfg.dataDir}/pictures/android-camera";
            devices = device-names;
          };
        };
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    users = lib.mkIf (cfg.user == "syncthing") {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
      groups.${cfg.group} = {};
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/syncthing" = {
        type = "zfs_fs";
        mountpoint = cfg.dataDir;
        options.mountpoint = "legacy";
        options.recordsize = "1M";
      };
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.zfsIntegration.enable [
      "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/syncthing".useTemplate = ["default"];
      };
    };
  };
}
