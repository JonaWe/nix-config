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
    port = lib.mkOption {
      type = lib.types.port;
      default = 9892;
      example = 9892;
      description = "Port that is used for headscale";
    };
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      # uses acme group to access certificates
      group = "acme";
      enable = true;
      port = cfg.port;
      address = "0.0.0.0";
      settings = {
        tls_key_path = "/var/lib/acme/pinkorca.de/key.pem";
        tls_cert_path = "/var/lib/acme/pinkorca.de/cert.pem";
        server_url = "https://headscale.pinkorca.de";
        logtail.enabled = false;
        dns = {
          base_domain = "head.scale";
          extra_records = [
            {
              name = "*.ts.pinkorca";
              type = "A";
              value = "100.64.0.2";
            }
          ];
        };
      };
      # package = pkgs.headscale;
    };

    environment.systemPackages = [config.services.headscale.package];

    services.nginx.virtualHosts."headscale.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
