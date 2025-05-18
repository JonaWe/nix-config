{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.stirling-pdf;
in {
  options.myconf.services.stirling-pdf = {
    enable = lib.mkEnableOption "Enable stirling pdf service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for stirling pdf";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8314;
      example = 8314;
      description = "Port that is used for stirling pdf";
    };
  };

  config = lib.mkIf cfg.enable {
    services.stirling-pdf = {
      enable = true;
      environment = {
        SERVER_PORT = cfg.port;
      };
    };
    services.nginx.virtualHosts."pdf.winkelsheim.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };

    services.nginx.virtualHosts."pdf.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
