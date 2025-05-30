{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.wallos;
in {
  options.myconf.services.wallos = {
    enable = lib.mkEnableOption "Enable wallos service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8235;
      example = 8235;
      description = "Port that is used for wallos";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/wallos";
      example = "/var/lib/wallos";
      description = "Base directory that is used to store wallos data";
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "wallos";
        description = "User that is used to run wallos";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2030;
        description = "User id that is used to run wallos";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2030;
        description = "Group id that is used to run wallos";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "wallos";
        description = "Group that is used to run wallos";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user.user} = {
      isNormalUser = true;
      home = cfg.dataDir;
      group = cfg.user.group;
      description = "User for the wallos";
      uid = cfg.user.uid;
    };

    users.groups.${cfg.user.group} = {
      gid = cfg.user.gid;
    };
    virtualisation.oci-containers.containers."wallos" = {
      image = "bellamy/wallos:latest";
      environment = {
        "PGID" = toString cfg.user.gid;
        "PUID" = toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      ports = [
        "127.0.0.1:${toString cfg.port}:80"
      ];
      volumes = [
        "${cfg.dataDir}/db:/var/www/html/db:rw"
        "${cfg.dataDir}/logo:/var/www/html/images/uploads/logos:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."wallos.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
