{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.gitea;
in {
  options.myconf.services.gitea = {
    enable = lib.mkEnableOption "Enable gitea service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for gitea";
    };
    baseDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/data/media/gitea";
      description = "Directory used for gitea data";
    };
    repoDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.baseDirectory}/repo";
      description = "Directory used for gitea repo data";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.gitea = rec {
      enable = true;
      user = "git";
      stateDir = cfg.baseDirectory;
      repositoryRoot = cfg.repoDirectory;
      database = {
        user = "git";
      };
      lfs = {
        enable = false;
        contentDir = "${stateDir}/lfs";
      };
      settings = {
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
        };
        session = {
          COOKIE_SECURE = true;
        };
        # service = {
        #   DISABLE_REGISTRATION = true;
        # };
        server = {
          HTTP_PORT = 3002;
          ROOT_URL = "https://gitea.home.pinkorca.de/";
          DOMAIN = "gitea.home.pinkorca.de";
          SSH_USER = "git";
        };
      };
    };

    users.users.git = {
      isSystemUser = true;
      useDefaultShell = true;
      group = "git";
      extraGroups = ["gitea"];
      home = cfg.baseDirectory;
    };
    users.groups.git = {};

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/gitea" = {
        type = "zfs_fs";
        mountpoint = cfg.baseDirectory;
        options.mountpoint = "legacy";
      };
      "enc/services/gitea/repos" = {
        type = "zfs_fs";
        mountpoint = cfg.repoDirectory;
        options.mountpoint = "legacy";
        # options.quota = "2T";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.baseDirectory} 0700 git gitea -"
      "d ${cfg.repoDirectory} 0700 git gitea -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/gitea".useTemplate = ["default"];
        "zdata/enc/services/gitea/repos".useTemplate = ["default"];
      };
    };

    services.nginx.virtualHosts."gitea.winkelsheim.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3002/";
      };
    };
    services.nginx.virtualHosts."gitea.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3002/";
      };
    };
  };
}
