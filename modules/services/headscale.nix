{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.headscale;
in {
  options.myconf.services.headscale = {
    enable = lib.mkEnableOption "Enable headscale service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5313;
      example = 5313;
      description = "Port that is used for headscale";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for headscale. Port 80, 443 and 3478 for STUN.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      port = cfg.port;
      address = "127.0.0.1";
      package = pkgs-unstable.headscale;
      settings = {
        server_url = "https://headscale.pinkorca.de";
        logtail.enabled = false;
        dns = {
          base_domain = "tail.net";
          nameservers.global = ["9.9.9.9"];
          extra_records = [
            {
              name = "*.ts.pinkorca";
              type = "A";
              value = "100.64.0.2";
            }
            {
              name = "*.ts.pinkorca";
              type = "AAAA";
              value = "fd7a:115c:a1e0::2";
            }
          ];
        };
        policy.path = pkgs.writeText "acl.json" (
          builtins.toJSON {
            groups = {
              "group:trusted" = [
                "Jona@pinkorca.de"
                "Noah@pinkorca.de"
                "Rahel@pinkorca.de"
                "Sofie@pinkorca.de"
                "Anton@pinkorca.de"
                "Johannes@pinkorca.de"
                "Niklas@pinkorca.de"
                "Aaron@pinkorca.de"
                "Ulli@pinkorca.de"
              ];
              "group:vpn" = [
                "Jona@pinkorca.de"
                "Sofie@pinkorca.de"
                "Ulli@pinkorca.de"
                "Noah@pinkorca.de"
              ];
            };
            acls = [
              {
                action = "accept";
                src = ["autogroup:member"];
                dst = ["autogroup:self:*"];
              }
              {
                action = "accept";
                src = [
                  "Infra@pinkorca.de"
                ];
                dst = [
                  "Infra@pinkorca.de:*"
                ];
              }
              {
                action = "accept";
                src = [
                  "group:trusted"
                ];
                dst = [
                  "Infra@pinkorca.de:*"
                ];
              }
              {
                action = "accept";
                src = [
                  "group:vpn"
                ];
                dst = [
                  "autogroup:internet:*"
                ];
              }
            ];
          }
        );
      };
    };

    services.nginx.virtualHosts."headscale.pinkorca.de" = {
      forceSSL = true;
      useACMEHost = "pinkorca.de";

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };

    environment.systemPackages = [pkgs-unstable.headscale];

    sops.secrets."porkbun/api-key" = {};
    sops.secrets."porkbun/secret-api-key" = {};

    users.users.headscale.extraGroups = ["acme"];

    security.acme = {
      certs."pinkorca.de".extraDomainNames = [
        "headscale.pinkorca.de"
        "auth.pinkorca.de"
      ];
    };
  };
}
