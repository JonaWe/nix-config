{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.headscale;
in {
  options.myconf.services.headscale = {
    enable = lib.mkEnableOption "Enable headscale service";
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      # port = cfg.port;
      address = "0.0.0.0";
      settings = {
        server_url = "https://headscale.pinkorca.de";
        logtail.enabled = false;
        dns = {
          base_domain = "head.scale";
        };
      };
      # package = pkgs.headscale;
    };

    environment.systemPackages = [config.services.headscale.package];

    services.nginx.virtualHosts."headscale.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.headscale.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
