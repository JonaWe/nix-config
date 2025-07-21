{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.paperless;
in {
  options.myconf.services.paperless = {
    enable = lib.mkEnableOption "Enable paperless service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for paperless";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 28981;
      example = 28981;
      description = "Port that is used for paperless";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.etc."paperless-admin-pass".text = "admin";
    services.paperless = {
      # passwordFile = "/etc/paperless-admin-pass";
      port = cfg.port;
      enable = true;
      # dataDir = "/var/lib/paperless";
      consumptionDir = "/data/syncthing/paperless-consume";
      consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_URL = "https://paperless.ts.pinkorca.de";
        PAPERLESS_ENABLE_HTTP_REMOTE_USER_API = "true";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };

    services.nginx.virtualHosts."paperless.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };

    # services.nginx.virtualHosts."paperless-ai.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
    #   useACMEHost = "pinkorca.de";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:3000/";
    #   };
    # };
    #
    # users.users.paperless-ai = {
    #   isNormalUser = true;
    #   home = "/var/lib/paperless-ai";
    #   group = "paperless-ai";
    #   description = "User for paperless-ai";
    #   uid = 133710;
    # };
    #
    # users.groups.paperless-ai = {
    #   gid = 133710;
    # };
    #
    # virtualisation.oci-containers.containers."paperless-ai" = {
    #   image = "clusterzx/paperless-ai";
    #   volumes = [
    #     "/var/lib/paperless-ai:/app/data"
    #   ];
    #   environment = {
    #     "PGID" = "133710";
    #     "PUID" = "133710";
    #     "PAPERLESS_AI_PORT" = "3000";
    #     "RAG_SERVICE_URL" = "http://localhost:8000";
    #     "RAG_SERVICE_ENABLED" = "true";
    #   };
    #   # ports = [
    #   # "127.0.0.1:3033:3033"
    #   # "127.0.0.1:3033:3000"
    #   # "28981"
    #   # "11434"
    #   # ];
    #   log-driver = "journald";
    #   extraOptions = [
    #     "--network=host"
    #     "--pull=always"
    #   ];
    # };
    #
    # systemd.tmpfiles.rules = [
    #   "d /var/lib/paperless-ai 0700 paperless-ai paperless-ai -"
    # ];

    # networking.firewall.allowedTCPPorts = [3000];

    # services:
    #   paperless-ai:
    #     image: clusterzx/paperless-ai
    #     container_name: paperless-ai
    #     network_mode: bridge
    #     restart: unless-stopped
    #     cap_drop:
    #       - ALL
    #     security_opt:
    #       - no-new-privileges=true
    #     environment:
    #       - PUID=1000
    #       - PGID=1000
    #       - PAPERLESS_AI_PORT=${PAPERLESS_AI_PORT:-3000}
    #       - RAG_SERVICE_URL=http://localhost:8000
    #       - RAG_SERVICE_ENABLED=true
    #     ports:
    #       - "3000:${PAPERLESS_AI_PORT:-3000}"
    #     volumes:
    #       - paperless-ai_data:/app/data
    #
    # volumes:
    #   paperless-ai_data:
  };
}
