{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.fluxer;

  version = "2026.1102.171206";
  domain = "fluxer.ts.pinkorca.de";
  tailnetAddress = "100.64.0.2";
  edgePort = 8095;
  dataDir = "/opt/services/fluxer";
  dataset = "zdata/enc/services/fluxer";
  volumeDirs = ["postgres" "valkey" "nats" "meilisearch" "seaweedfs" "edge-data" "edge-config"];

  bundle = pkgs.fetchzip {
    url = "https://github.com/fluxerapp/fluxer/releases/download/fluxer-release%40${version}/fluxer-compose-${version}.tar.gz";
    hash = "sha256-+EcOnXlplSokUFNqaKlQDtNSvoUIDcAKQSoVQMfB7Zg=";
    stripRoot = false;
  };

  etc = config.environment.etc;
  docker = "${config.virtualisation.docker.package}/bin/docker";
  compose = lib.concatStringsSep " " [
    "${docker} compose -p fluxer"
    "-f ${bundle}/docker-compose.yml"
    "-f ${bundle}/docker-compose.proxy.yml"
    "-f /etc/fluxer/compose.override.yml"
    "--env-file /etc/fluxer/settings.env"
    "--env-file ${config.sops.secrets."fluxer/env".path}"
  ];
in {
  options.myconf.services.fluxer = {
    enable = lib.mkEnableOption "Enable Fluxer chat and voice";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    sops.secrets."fluxer/env".restartUnits = ["fluxer.service"];

    environment.etc."fluxer/settings.env".text = ''
      FLUXER_SETTINGS_LOADED=true
      FLUXER_DOMAIN=${domain}
      FLUXER_EDGE_BIND=127.0.0.1:${toString edgePort}
      FLUXER_LIVEKIT_USE_EXTERNAL_IP=false
      FLUXER_LIVEKIT_NODE_IP=${tailnetAddress}
      FLUXER_S3_ACCESS_KEY=fluxer
      LIVEKIT_API_KEY=fluxer

      FLUXER_POSTGRES_MEMORY_LIMIT=1gb
      FLUXER_POSTGRES_MEMORY_RESERVATION=0
      FLUXER_POSTGRES_SHARED_BUFFERS=256MB
      FLUXER_POSTGRES_EFFECTIVE_CACHE_SIZE=768MB
      FLUXER_POSTGRES_SHM_SIZE=256mb
      FLUXER_API_MEMORY_LIMIT=768mb
      FLUXER_API_MEMORY_RESERVATION=0
      FLUXER_WORKER_MEMORY_LIMIT=768mb
      FLUXER_WORKER_MEMORY_RESERVATION=0
      FLUXER_MEILISEARCH_MEMORY_LIMIT=512mb
      FLUXER_SEAWEEDFS_MEMORY_LIMIT=512mb
      FLUXER_SEAWEEDFS_GOMEMLIMIT=400MiB
    '';

    environment.etc."fluxer/compose.override.yml".text = ''
      services:
        postgres:
          volumes:
            - ${dataDir}/postgres:/var/lib/postgresql/data
        valkey:
          volumes:
            - ${dataDir}/valkey:/data
        nats:
          volumes:
            - ${dataDir}/nats:/data
        meilisearch:
          volumes:
            - ${dataDir}/meilisearch:/meili_data
        seaweedfs:
          volumes:
            - ${dataDir}/seaweedfs:/data
        edge:
          volumes:
            - ${dataDir}/edge-data:/data
            - ${dataDir}/edge-config:/config
        livekit:
          ports: !override
            - "${tailnetAddress}:7881:7881"
            - "${tailnetAddress}:7882:7882/udp"
    '';

    systemd.services.fluxer = {
      description = "Fluxer chat (docker compose)";
      after = ["docker.service" "network-online.target"];
      requires = ["docker.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      restartTriggers = [
        bundle
        etc."fluxer/settings.env".source
        etc."fluxer/compose.override.yml".source
      ];
      unitConfig.RequiresMountsFor = [dataDir];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "30min";
        Restart = "on-failure";
        RestartSec = "30s";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${lib.concatMapStringsSep " " (d: "${dataDir}/${d}") volumeDirs}";
        ExecStart = "${compose} up -d --remove-orphans --wait";
        ExecStop = "${compose} down";
      };
    };

    fileSystems.${dataDir} = {
      device = dataset;
      fsType = "zfs";
    };

    services.sanoid.datasets.${dataset}.useTemplate = ["default"];
    homelab.extraBackupDatasets = [dataset];

    services.nginx.virtualHosts.${domain} = {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      http2 = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString edgePort}";
        proxyWebsockets = true;
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          client_max_body_size 512m;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          proxy_buffering off;
          proxy_request_buffering off;
        '';
      };
    };
  };
}
