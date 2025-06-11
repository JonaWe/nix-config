{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.unifi-controller;
in {
  options.myconf.services.unifi-controller = {
    enable = lib.mkEnableOption "Enable unifi-controller service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9583;
      example = 9583;
      description = "Port that is used for unifi";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/unifi";
      example = "/var/lib/unifi";
      description = "Base directory that is used to store unifi data";
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "unifi";
        description = "User that is used to run unifi";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2090;
        description = "User id that is used to run unifi";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2090;
        description = "Group id that is used to run unifi";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "unifi";
        description = "Group that is used to run unifi";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user.user} = {
      isSystemUser = true;
      # home = cfg.dataDir;
      group = cfg.user.group;
      description = "User for the unifi";
      uid = cfg.user.uid;
    };

    users.groups.${cfg.user.group} = {
      gid = cfg.user.gid;
    };

    # networking.firewall.allowedUDPPorts = [
    #   3478
    # ];
    #
    # networking.firewall.allowedTCPPorts = [
    #   cfg.port
    #   8443
    # ];

    networking.firewall.allowedTCPPorts = [8443 8080 8880 8843];
    networking.firewall.allowedUDPPorts = [3478 10001];

    virtualisation.oci-containers.containers."unifi-controller" = {
      image = "jacobalberty/unifi:latest";
      environment = {
        "PGID" = toString cfg.user.gid;
        "PUID" = toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };

      ports = [
        "8443:8443" # Controller UI
        "8080:8080" # Device inform
        "8880:8880" # Guest portal
        "8843:8843" # Guest portal HTTPS
        "3478:3478/udp" # STUN
        "10001:10001/udp" # AP discovery
      ];
      volumes = [
        "${cfg.dataDir}:/unifi:rw"
      ];
      user = cfg.user.user;
      # group = cfg.sroup;
      log-driver = "journald";
      extraOptions = [
        # "--network=host"
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."unifi.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://localhost:8843/";
      };
    };
  };
}
