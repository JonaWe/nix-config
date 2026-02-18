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
      slskd = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/slskd";
        description = "Directory for slskd runtime config";
      };
      navidrome = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/navidrome";
        description = "Directory for navidrome config";
      };
      picard = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/picard";
        description = "Directory for picard config";
      };
      dispatcharr = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/dispatcharr";
        description = "Directory for dispatcharr config";
      };
      sabnzbd = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/sabnzbd";
        description = "Directory for sabnzbd config";
      };
      jellyfin = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/jellyfin2";
        description = "Directory for bazarr runtime config";
      };
      readmeabook = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.libDir.base}/readmeabook";
        description = "Directory for readmeabook runtime config";
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
      audiobooks = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Audiobooks";
        description = "Directory for audiobooks";
      };
      podcasts = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir.base}/Podcasts";
        description = "Directory for podcasts";
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
        default = 8055;
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
    slskd = {
      enable = lib.mkEnableOption "Enable slskd service";
      openFirewall = lib.mkEnableOption "Open firewall for slskd web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 9951;
        description = "Default port for slskd web ui";
      };
    };
    navidrome = {
      enable = lib.mkEnableOption "Enable navidrome service";
      openFirewall = lib.mkEnableOption "Open firewall for navidrome web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 4533;
        description = "Default port for navidrome web ui";
      };
    };
    dispatcharr = {
      enable = lib.mkEnableOption "Enable dispatcharr service";
      openFirewall = lib.mkEnableOption "Open firewall for dispatcharr web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 9191;
        description = "Default port for dispatcharr web ui";
      };
    };
    sabnzbd = {
      enable = lib.mkEnableOption "Enable sabnzbd service";
      openFirewall = lib.mkEnableOption "Open firewall for sabnzbd web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8513;
        description = "Default port for sabnzbd web ui";
      };
    };
    readmeabook = {
      enable = lib.mkEnableOption "Enable readmeabook service";
      openFirewall = lib.mkEnableOption "Open firewall for readmeabook web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3030;
        description = "Default port for readmeabook web ui";
      };
    };
    picard = {
      enable = lib.mkEnableOption "Enable picard service";
      openFirewall = lib.mkEnableOption "Open firewall for picard web ui";
      port = lib.mkOption {
        type = lib.types.port;
        default = 5800;
        description = "Default port for picard web ui";
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
      "audiobookshelf.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8654/";
          proxyWebsockets = true;
        };
      };
      "recommendarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.recommendarr.port}/";
        };
      };
      "sonarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.sonarr.port}/";
        };
      };
      "readarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.readarr.port}/";
        };
      };
      "prowlarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.prowlarr.port}/";
        };
      };
      "qbittorrent.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.qbittorrent.port}/";
        };
      };
      "jellyseerr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.jellyseerr.port}/";
        };
      };
      "bazarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.bazarr.port}/";
        };
      };
      "slskd.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:5030";
        };
      };
      "dispatcharr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.dispatcharr.port}";
          proxyWebsockets = true;
        };
      };
      "navidrome.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.navidrome.port}";
        };
      };
      "picard.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.picard.port}";
        };
      };
      "lidarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.lidarr.port}/";
        };
      };
      "radarr.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.radarr.port}/";
        };
      };
      "sabnzbd.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.sabnzbd.port}/";
        };
      };
      "readmeabook.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${builtins.toString cfg.readmeabook.port}/";
          # proxyWebsockets = true;
        };
      };
      "jellyfin2.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
        useACMEHost = "pinkorca.de";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:9999/";
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

    virtualisation.oci-containers.containers."jellyfin" = lib.mkIf cfg.sonarr.enable {
      image = "jellyfin/jellyfin:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      ports = [
        "9999:8096"
        # More port mappings as needed
      ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.jellyfin}:/config:rw"
        "${cfg.dataDir.tvshows}:/TVShows:rw"
        "${cfg.dataDir.movies}:/Movies:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    # directories
    systemd.tmpfiles.rules =
      [
        "d ${cfg.dataDir.base} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.downloads} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.movies} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.tvshows} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.books} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.audiobooks} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.podcasts} 0700 ${cfg.user.user} ${cfg.user.group} -"
        "d ${cfg.dataDir.music} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.recommendarr.enable [
        "d ${cfg.libDir.recommendarr} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.recommendarr.enable [
        "d ${cfg.libDir.jellyfin} 0700 ${cfg.user.user} ${cfg.user.group} -"
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
      ]
      ++ lib.lists.optionals cfg.slskd.enable [
        "d ${cfg.libDir.slskd} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.navidrome.enable [
        "d ${cfg.libDir.navidrome} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.dispatcharr.enable [
        "d ${cfg.libDir.dispatcharr} 0755 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.sabnzbd.enable [
        "d ${cfg.libDir.sabnzbd} 0755 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.readmeabook.enable [
        "d ${cfg.libDir.readmeabook} 0755 ${cfg.user.user} ${cfg.user.group} -"
      ]
      ++ lib.lists.optionals cfg.picard.enable [
        "d ${cfg.libDir.picard} 0700 ${cfg.user.user} ${cfg.user.group} -"
      ];

    services.audiobookshelf = {
      enable = true;
      port = 8654;
      user = "arr";
      group = "arr";
    };

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
        ["8096" "11434" "443"]
        ++ lib.lists.optionals cfg.qbittorrent.openFirewall [
          "127.0.0.1:${builtins.toString cfg.recommendarr.port}:8765/tcp"
        ]
        ++ lib.lists.optionals cfg.qbittorrent.openFirewall [
          "127.0.0.1:${builtins.toString cfg.qbittorrent.port}:${toString cfg.qbittorrent.port}/tcp"
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
        ++ lib.lists.optionals cfg.jellyseerr.openFirewall [
          "127.0.0.1:5030:5030/tcp"
        ]
        ++ lib.lists.optionals cfg.jellyseerr.openFirewall [
          "127.0.0.1:5031:5031/tcp"
        ]
        ++ lib.lists.optionals cfg.navidrome.openFirewall [
          "127.0.0.1:${builtins.toString cfg.navidrome.port}:4533/tcp"
        ]
        ++ lib.lists.optionals cfg.picard.openFirewall [
          "127.0.0.1:${builtins.toString cfg.picard.port}:${builtins.toString cfg.picard.port}/tcp"
        ]
        ++ lib.lists.optionals cfg.dispatcharr.openFirewall [
          "127.0.0.1:${builtins.toString cfg.dispatcharr.port}:${builtins.toString cfg.dispatcharr.port}/tcp"
        ]
        # ++ lib.lists.optionals cfg.readmeabook.openFirewall [
        #   "127.0.0.1:${builtins.toString cfg.readmeabook.port}:${builtins.toString cfg.readmeabook.port}/tcp"
        # ]
        ++ lib.lists.optionals cfg.sabnzbd.openFirewall [
          "127.0.0.1:${builtins.toString cfg.sabnzbd.port}:8080/tcp"
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

    systemd.services."docker-dispatcharr" = lib.mkIf cfg.dispatcharr.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."dispatcharr" = lib.mkIf cfg.dispatcharr.enable {
      image = "ghcr.io/dispatcharr/dispatcharr:latest";
      # user = "2010:2010";
      environment = {
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.dispatcharr}:/data:rw"
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

    systemd.services."docker-sabnzbd" = lib.mkIf cfg.sabnzbd.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."sabnzbd" = lib.mkIf cfg.sabnzbd.enable {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.sabnzbd}:/config:rw"
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

    systemd.services."docker-navidrome" = lib.mkIf cfg.navidrome.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."navidrome" = lib.mkIf cfg.navidrome.enable {
      image = "deluan/navidrome:latest";
      # user = "arr:arr";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.navidrome}:/data:rw"
        "${cfg.dataDir.music}/Library:/music:rw"
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

    systemd.services."docker-picard" = lib.mkIf cfg.picard.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."picard" = lib.mkIf cfg.picard.enable {
      image = "mikenye/picard:latest";
      environment = {
        # "USER_ID" = builtins.toString cfg.user.gid;
        # "GROUP_ID" = builtins.toString cfg.user.uid;
        "USER_ID" = "0";
        "GROUP_ID" = "0";
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.libDir.picard}:/config:rw"
        "${cfg.dataDir.music}:/Music:rw"
        # "${cfg.libDir.slskd}/downloads:/downloads:rw"
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
      image = "blampe/lidarr:latest";
      # image = "lscr.io/linuxserver/lidarr:latest";
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

    # systemd.services."docker-lidarr" = lib.mkIf cfg.lidarr.enable defaultSystemDConfig;
    # virtualisation.oci-containers.containers."lidarr" = lib.mkIf cfg.lidarr.enable {
    #   image = "linuxserver/lidarr:latest";
    #   environment = {
    #     "PGID" = builtins.toString cfg.user.gid;
    #     "PUID" = builtins.toString cfg.user.uid;
    #     "TZ" = "Europe/Berlin";
    #   };
    #   volumes = [
    #     "${cfg.libDir.lidarr}:/app/config:rw"
    #     "${cfg.dataDir.downloads}:/downloads:rw"
    #     "${cfg.dataDir.music}:/Music:rw"
    #   ];
    #   dependsOn = [
    #     "gluetun"
    #   ];
    #   log-driver = "journald";
    #   extraOptions = [
    #     "--pull=always"
    #     "--network=container:gluetun"
    #   ];
    # };

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
        "WEBUI_PORT" = "${toString cfg.qbittorrent.port}";
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

    systemd.services."docker-slskd" = lib.mkIf cfg.slskd.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."slskd" = lib.mkIf cfg.slskd.enable {
      image = "slskd/slskd:latest";
      # user = "arr:arr";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
        "SLSKD_REMOTE_CONFIGURATION" = "true";
        "SLSKD_SHARED_DIR" = "/Music";
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.libDir.slskd}:/app:rw"
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

    systemd.services."docker-readmeabook" = lib.mkIf cfg.readmeabook.enable defaultSystemDConfig;
    virtualisation.oci-containers.containers."readmeabook" = lib.mkIf cfg.readmeabook.enable {
      image = "ghcr.io/kikootwo/readmeabook:latest";
      environment = {
        "PGID" = builtins.toString cfg.user.gid;
        "PUID" = builtins.toString cfg.user.uid;
        "TZ" = "Europe/Berlin";
        "PUBLIC_URL" = "https://readmeabook.ts.pinkorca.de";
      };
      volumes = [
        "${cfg.libDir.readmeabook}/config:/app/config:rw"
        "${cfg.libDir.readmeabook}/cache:/app/cache:rw"
        "${cfg.dataDir.books}:/Books:rw"
        "${cfg.dataDir.audiobooks}:/Audiobooks:rw"
        "${cfg.dataDir.downloads}:/downloads:rw"
      ];
      ports = [
        "127.0.0.1:${toString cfg.readmeabook.port}:3030"
      ];
      # dependsOn = [
      #   "gluetun"
      # ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        # "--network=container:gluetun"
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
        "${cfg.dataDir.audiobooks}:/Audiobooks:rw"
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
        docker build -t tannermiddleton/recommendarr:latest --build-arg BASE_URL=https://recommendarr.ts.pinkorca.de .
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
        "PUBLIC_URL" = "https://recommendarr.ts.pinkorca.de";

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
