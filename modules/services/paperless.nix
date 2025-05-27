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
    environment.etc."paperless-admin-pass".text = "admin";
    services.paperless = {
      passwordFile = "/etc/paperless-admin-pass";
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
        PAPERLESS_URL = "https://paperless.home.pinkorca.de";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };

    services.nginx.virtualHosts."paperless.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
