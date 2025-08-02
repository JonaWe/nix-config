{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.metube;
in {
  options.myconf.services.metube = {
    enable = lib.mkEnableOption "Enable metube service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9209;
      example = 9209;
      description = "Port that is used for metube";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/metube";
      example = "/var/lib/metube";
      description = "Base directory that is used to store metube data";
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "metube";
        description = "User that is used to run metube";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2028;
        description = "User id that is used to run metube";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2028;
        description = "Group id that is used to run metube";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "metube";
        description = "Group that is used to run metube";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user.user} = {
      isNormalUser = true;
      home = cfg.dataDir;
      group = cfg.user.group;
      description = "User for the metube";
      uid = cfg.user.uid;
    };

    users.groups.${cfg.user.group} = {
      gid = cfg.user.gid;
    };

    virtualisation.oci-containers.containers."metube" = {
      image = "ghcr.io/alexta69/metube";
      environment = {
        "GID" = toString cfg.user.gid;
        "UID" = toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      ports = [
        "${toString cfg.port}:8081"
      ];
      volumes = [
        "${cfg.dataDir}:/downloads:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."metube.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
