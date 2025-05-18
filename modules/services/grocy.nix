{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.grocy;
in {
  options.myconf.services.grocy = {
    enable = lib.mkEnableOption "Enable grocy service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9283;
      example = 9283;
      description = "Port that is used for grocy";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/grocy";
      example = "/var/lib/grocy";
      description = "Base directory that is used to store grocy data";
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "grocy";
        description = "User that is used to run grocy";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2020;
        description = "User id that is used to run grocy";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2020;
        description = "Group id that is used to run grocy";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "grocy";
        description = "Group that is used to run grocy";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user.user} = {
      isNormalUser = true;
      home = cfg.dataDir;
      group = cfg.user.group;
      description = "User for the grocy";
      uid = cfg.user.uid;
    };

    users.groups.${cfg.user.group} = {
      gid = cfg.user.gid;
    };
    virtualisation.oci-containers.containers."grocy" = {
      image = "lscr.io/linuxserver/grocy:latest";
      environment = {
        "PGID" = toString cfg.user.gid;
        "PUID" = toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      ports = [
        "${toString cfg.port}:80"
      ];
      volumes = [
        "${cfg.dataDir}:/config:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."grocy.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
