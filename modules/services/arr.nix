{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.arr;
in {
  options.myconf.services.arr = {
    enable = lib.mkEnableOption "Enable *arr app suite for media management";
    libDir = {
      base = lib.mkOption {
        type = lib.types.path;
        example = "/data/media/arr";
        description = "Base directory where service config is stored";
      };
      jellyseerr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/jellyseerr";
        description = "Directory for jellyseerr runtime config";
      };
      prowlarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/prowlarr";
        description = "Directory for prowlarr runtime config";
      };
      qbittorrent = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/qbittorrent";
        description = "Directory for qbittorrent runtime config";
      };
      radarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/radarr";
        description = "Directory for radarr runtime config";
      };
      readarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/readarr";
        description = "Directory for readarr runtime config";
      };
      sonarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/sonarr";
        description = "Directory for sonarr runtime config";
      };
      bazarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/bazarr";
        description = "Directory for bazarr runtime config";
      };
    };
    dataDir = {
      base = lib.mkOption {
        type = lib.types.path;
        example = "/data/media/arr/data";
        description = "Base directory that is used to store the arr data";
      };
      downloads = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Downloads";
        description = "Directory where the downloads are stored";
      };
      movies = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Movies";
        description = "Directory for movies";
      };
      tvshows = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/TVShows";
        description = "Directory for tv shows";
      };
      books = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Books";
        description = "Directory for books";
      };
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "arr";
        description = "User that is used to run arr apps";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2010;
        description = "User id that is used to run arr apps";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2010;
        description = "Group id that is used to run arr apps";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "arr";
        description = "Group that is used to run arr apps";
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-arr-root.target"
    ];
    wantedBy = [
      "docker-compose-arr-root.target"
    ];
    defaultSystemDConfig = {
      inherit serviceConfig;
      inherit partOf;
      inherit wantedBy;
    };
  in {
    sops.secrets."arr/vpn/env" = {};

    # users
    users.users.${cfg.user.user} = {
      isNormalUser = true;
      home = cfg.dataDir.base;
      group = cfg.user.group;
      description = "User for the arr apps";
      uid = cfg.user.uid;
    };

    users.groups.${cfg.user.group} = {
      gid = cfg.user.gid;
    };

    # directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir.base} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.dataDir.downloads} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.dataDir.movies} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.dataDir.tvshows} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.dataDir.books} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.jellyseerr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.prowlarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.qbittorrent} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.radarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.readarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.sonarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      "d ${cfg.libDir.bazarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
    ];

    # runtime
    virtualisation.docker = {
      enable = lib.mkDefault true;
      autoPrune.enable = lib.mkDefault true;
    };
    virtualisation.oci-containers.backend = "docker";

    # containers
    systemd.services."docker-flaresolverr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."flaresolverr" = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        "LOG_LEVEL" = "info";
      };
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-gluetun" = {
      inherit serviceConfig;
      inherit partOf;
      inherit wantedBy;
      after = [
        "docker-network-arr_default.service"
      ];
      requires = [
        "docker-network-arr_default.service"
      ];
    };
    virtualisation.oci-containers.containers."gluetun" = {
      image = "qmcgaw/gluetun";
      environmentFiles = [config.sops.secrets."arr/vpn/env".path];
      ports = [
        "8080:8080/tcp" # qbittorrent
        "9696:9696/tcp" # prowlarr
        "8989:8989/tcp" # sonarr
        "7878:7878/tcp" # radarr
        "8787:8787/tcp" # readarr
        "8686:8686/tcp" # lidarr
        "5055:5055/tcp" # jellyseerr
        "6767:6767/tcp" # bazarr
        # "8096:8096/tcp"
      ];
      log-driver = "journald";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun:rwm"
        "--network-alias=gluetun"
        "--network=arr_default"
      ];
    };

    systemd.services."docker-bazarr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."bazarr" = {
      image = "lscr.io/linuxserver/bazarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.bazarr}:/app/config:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-jellyseerr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."jellyseerr" = {
      image = "fallenbagel/jellyseerr:latest";
      environment = {
        "LOG_LEVEL" = "info";
        "PORT" = "5055";
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.jellyseerr}:/app/config:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-prowlarr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."prowlarr" = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.prowlarr}:/config:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-qbittorrent" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."qbittorrent" = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TORRENTING_PORT" = "6881";
        "TZ" = "Europe/Berlin";
        "WEBUI_PORT" = "8080";
      };
      volumes = [
        "${cfg.libDir.qbittorrent}:/config:rw"
        "${cfg.dataDir.downloads}:/downloads:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-radarr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."radarr" = {
      image = "lscr.io/linuxserver/radarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.radarr}:/config:rw"
        "${cfg.dataDir.downloads}:/Downloads:rw"
        "${cfg.dataDir.movies}:/Movies:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-readarr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."readarr" = {
      image = "lscr.io/linuxserver/readarr:develop";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.readarr}:/config:rw"
        "${cfg.dataDir.books}:/Books:rw"
        "${cfg.dataDir.downloads}:/Downloads:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-sonarr" = defaultSystemDConfig;
    virtualisation.oci-containers.containers."sonarr" = {
      image = "lscr.io/linuxserver/sonarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.sonarr}:/config:rw"
        "${cfg.dataDir.tvshows}:/TVShows:rw"
        "${cfg.dataDir.downloads}:/Downloads:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=container:gluetun"
      ];
    };

    # networks
    systemd.services."docker-network-arr_default" = {
      path = [pkgs.docker];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f arr_default";
      };
      script = ''
        docker network inspect arr_default || docker network create arr_default
      '';
      partOf = ["docker-compose-arr-root.target"];
      wantedBy = ["docker-compose-arr-root.target"];
    };

    # Root service
    # When started, this will automatically create all resources and start
    # the containers. When stopped, this will teardown all resources.
    systemd.targets."docker-compose-arr-root" = {
      unitConfig = {
        Description = "Root docker target for arr apps";
      };
      wantedBy = ["multi-user.target"];
    };
  });
}
