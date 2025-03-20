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
      recommendarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/recommendarr";
        description = "Directory for recommendarr runtime config";
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
      lidarr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/lidarr";
        description = "Directory for lidarr runtime config";
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
      music = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Music";
        description = "Directory for music";
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
    recommendarr = {
      enable = lib.mkEnableOption "Enable recommendarr service";
      openFirewall = lib.mkEnableOption "Open firewall for recommendarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8765;
        description = "Default port for recommendarr web ui";
      };
    };
    qbittorrent = {
      enable = lib.mkEnableOption "Enable qbittorrent service";
      openFirewall = lib.mkEnableOption "Open firewall for qbittorrent web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Default port for qbittorrent web ui";
      };
    };
    prowlarr = {
      enable = lib.mkEnableOption "Enable prowlarr service";
      openFirewall = lib.mkEnableOption "Open firewall for prowlarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 9696;
        description = "Default port for prowlarr web ui";
      };
    };
    sonarr = {
      enable = lib.mkEnableOption "Enable sonarr service";
      openFirewall = lib.mkEnableOption "Open firewall for sonarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8989;
        description = "Default port for sonarr web ui";
      };
    };
    flaresolverr = {
      enable = lib.mkEnableOption "Enable flaresolverr service";
    };
    radarr = {
      enable = lib.mkEnableOption "Enable radarr service";
      openFirewall = lib.mkEnableOption "Open firewall for radarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 7878;
        description = "Default port for radarr web ui";
      };
    };
    readarr = {
      enable = lib.mkEnableOption "Enable readarr service";
      openFirewall = lib.mkEnableOption "Open firewall for readarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8787;
        description = "Default port for readarr web ui";
      };
    };
    lidarr = {
      enable = lib.mkEnableOption "Enable lidarr service";
      openFirewall = lib.mkEnableOption "Open firewall for lidarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8686;
        description = "Default port for lidarr web ui";
      };
    };
    jellyseerr = {
      enable = lib.mkEnableOption "Enable jellyseerr service";
      openFirewall = lib.mkEnableOption "Open firewall for jellyseerr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 5055;
        description = "Default port for jellyseerr web ui";
      };
    };
    bazarr = {
      enable = lib.mkEnableOption "Enable bazarr service";
      openFirewall = lib.mkEnableOption "Open firewall for bazarr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Default port for bazarr web ui";
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

    services.nginx.virtualHosts = {
      "recommendarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.recommendarr.port}/";
        };
      };
      "sonarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.sonarr.port}/";
        };
      };
      "readarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.readarr.port}/";
        };
      };
      "prowlarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.prowlarr.port}/";
        };
      };
      "qbittorrent.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.qbittorrent.port}/";
        };
      };
      "jellyseerr.winkelsheim.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.jellyseerr.port}/";
        };
      };
      "jellyseerr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.jellyseerr.port}/";
        };
      };
      "bazarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.bazarr.port}/";
        };
      };
      "lidarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.lidarr.port}/";
        };
      };
      "radarr.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.radarr.port}/";
        };
      };
    };

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

    myconf.disk.dataPool.extraDatasets = lib.mkIf config.myconf.services.jellyfin.zfsIntegration.enable {
      "enc/services/arr" = {
        type = "zfs_fs";
        mountpoint = cfg.libDir.base;
        options.mountpoint = "legacy";
      };
    };

    # directories
    systemd.tmpfiles.rules =
      [
        "d ${cfg.dataDir.base} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.downloads} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.movies} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.tvshows} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.books} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.music} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.recommendarr.enable [
        "d ${cfg.libDir.recommendarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.jellyseerr.enable [
        "d ${cfg.libDir.jellyseerr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.prowlarr.enable [
        "d ${cfg.libDir.prowlarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.qbittorrent.enable [
        "d ${cfg.libDir.qbittorrent} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.radarr.enable [
        "d ${cfg.libDir.radarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.lidarr.enable [
        "d ${cfg.libDir.lidarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.readarr.enable [
        "d ${cfg.libDir.readarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.sonarr.enable [
        "d ${cfg.libDir.sonarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.bazarr.enable [
        "d ${cfg.libDir.bazarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ];

    # runtime
    virtualisation.docker = {
      enable = lib.mkDefault true;
      autoPrune.enable = lib.mkDefault true;
    };
    virtualisation.oci-containers.backend = "docker";

    # containers
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
      environment = {
        FIREWALL_OUTBOUND_SUBNETS = "10.1.1.0/24";
      };
      ports =
        ["8096" "11434"]
        ++ lib.lists.optionals cfg.qbittorrent.openFirewall [
          "127.0.0.1:${builtins.toString cfg.recommendarr.port}:8765/tcp"
        ]
        ++ lib.lists.optionals cfg.qbittorrent.openFirewall [
          "127.0.0.1:${builtins.toString cfg.qbittorrent.port}:8080/tcp"
        ]
        ++ lib.lists.optionals cfg.prowlarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.prowlarr.port}:9696/tcp"
        ]
        ++ lib.lists.optionals cfg.sonarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.sonarr.port}:8989/tcp"
        ]
        ++ lib.lists.optionals cfg.radarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.radarr.port}:7878/tcp"
        ]
        ++ lib.lists.optionals cfg.readarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.readarr.port}:8787/tcp"
        ]
        ++ lib.lists.optionals cfg.lidarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.lidarr.port}:8686/tcp"
        ]
        ++ lib.lists.optionals cfg.jellyseerr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.jellyseerr.port}:5055/tcp"
        ]
        ++ lib.lists.optionals cfg.bazarr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.bazarr.port}:6767/tcp"
        ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun:rwm"
        "--network-alias=gluetun"
        "--network=arr_default"
      ];
    };

    systemd.services."docker-flaresolverr" = lib.mkIf cfg.flaresolverr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."flaresolverr" = lib.mkIf cfg.flaresolverr.enable {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        "LOG_LEVEL" = "info";
      };
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-bazarr" = lib.mkIf cfg.bazarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."bazarr" = lib.mkIf cfg.bazarr.enable {
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
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-lidarr" = lib.mkIf cfg.lidarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."lidarr" = lib.mkIf cfg.lidarr.enable {
      image = "lscr.io/linuxserver/lidarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.lidarr}:/app/config:rw"
        "${cfg.dataDir.downloads}:/downloads:rw"
        "${cfg.dataDir.music}:/Music:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-jellyseerr" = lib.mkIf cfg.jellyseerr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."jellyseerr" = lib.mkIf cfg.jellyseerr.enable {
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
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-prowlarr" = lib.mkIf cfg.flaresolverr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."prowlarr" = lib.mkIf cfg.flaresolverr.enable {
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
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-qbittorrent" = lib.mkIf cfg.qbittorrent.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."qbittorrent" = lib.mkIf cfg.qbittorrent.enable {
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
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-radarr" = lib.mkIf cfg.radarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."radarr" = lib.mkIf cfg.radarr.enable {
      image = "lscr.io/linuxserver/radarr:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.radarr}:/config:rw"
        "${cfg.dataDir.downloads}:/downloads:rw"
        "${cfg.dataDir.movies}:/Movies:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-readarr" = lib.mkIf cfg.readarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."readarr" = lib.mkIf cfg.readarr.enable {
      image = "lscr.io/linuxserver/readarr:develop";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.readarr}:/config:rw"
        "${cfg.dataDir.books}:/Books:rw"
        "${cfg.dataDir.downloads}:/downloads:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    systemd.services."docker-sonarr" = lib.mkIf cfg.sonarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."sonarr" = lib.mkIf cfg.sonarr.enable {
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
        "${cfg.dataDir.downloads}:/downloads:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=container:gluetun"
      ];
    };

    # Builds
    systemd.services."docker-build-recommendarr" = {
      path = [pkgs.docker pkgs.git];
      serviceConfig = {
        Type = "oneshot";
        TimeoutSec = 300;
      };
      script = ''
        cd /tmp/docker-recommendarr-build
        docker build -t tannermiddleton/recommendarr:latest --build-arg BASE_URL=https://recommendarr.home.pinkorca.de .
      '';
    };

    systemd.services."docker-recommendarr" = lib.mkIf cfg.recommendarr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."recommendarr" = lib.mkIf cfg.recommendarr.enable {
      image = "tannermiddleton/recommendarr:latest";
      environment = {
        "DOCKER_ENV" = "true";
        "FORCE_SECURE_COOKIES" = "true";
        "NODE_ENV" = "production";
        "PORT" = "8765";
        "PUBLIC_URL" = "https://recommendarr.home.pinkorca.de";

        # "PGID" = builtins.toString cfg.user.gid;
        # "PUID" = builtins.toString cfg.user.uid;
        # "TZ" = "Europe/Berlin";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.recommendarr}:/app/server/data:rw"
      ];
      dependsOn = [
        "gluetun"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
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
