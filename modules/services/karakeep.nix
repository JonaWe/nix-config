{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.karakeep;
in {
  options.myconf.services.karakeep = {
    enable = lib.mkEnableOption "Enable karakeep bookmark service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5599;
      example = 5599;
      description = "Port that is used for karakeep";
    };
  };

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      meilisearch.enable = true;
      extraEnvironment = {
        PORT = toString cfg.port;
        # DISABLE_SIGNUPS = "false";
        DISABLE_NEW_RELEASE_CHECK = "true";
        CRAWLER_FULL_PAGE_SCREENSHOT = "true";
        CRAWLER_FULL_PAGE_ARCHIVE = "true";
      };
    };
    services.meilisearch.package = pkgs.meilisearch;
    # services.meilisearch.dumplessUpgrade = true;

    services.nginx.virtualHosts."karakeep.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
