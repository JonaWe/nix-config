{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.nginx;
in {
  options.myconf.services.nginx = {
    enable = lib.mkEnableOption "Enable Nginx Reverse Proxy";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for nginx. Port 80 and 443";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      80
      443
    ];
    sops.secrets."porkbun/api-key" = {};
    sops.secrets."porkbun/secret-api-key" = {};
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "_" = {
          useACMEHost = "pinkorca.de";
          addSSL = true;
          default = true;
          locations."/" = {
            root = pkgs.writeTextDir "index.html" ''
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>home.pinkorca.de</title>
                  <style>
                      body {
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                          background-color: black;
                          color: white;
                          font-size: 2em;
                      }
                  </style>
              </head>
              <body>
                  Hello!
              </body>
              </html>
            '';
            index = "index.html";
          };
        };
      };
    };

    users.users.nginx.extraGroups = ["acme"];
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "dev@pinkorca.de";
        dnsProvider = "porkbun";
        reloadServices = ["nginx"];
        credentialFiles = {
          "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun/api-key".path;
          "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun/secret-api-key".path;
        };
      };
      certs."pinkorca.de".extraDomainNames = [
        "*.pinkorca.de"
        "*.home.pinkorca.de"
        "*.winkelsheim.pinkorca.de"
        "*.ts.pinkorca.de"
      ];
    };
  };
}
