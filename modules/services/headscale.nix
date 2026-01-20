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
      default = 443;
      example = 443;
      description = "Port that is used for headscale";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for headscale. Port 80, 443 and 3478 for STUN.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      # needed when setting up acme
      # 80
      443
    ];

    # networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [
    #   3478
    #   41641
    # ];

    services.headscale = {
      enable = true;
      port = cfg.port;
      address = "0.0.0.0";
      package = pkgs-unstable.headscale;
      settings = {
        tls_key_path = "/var/lib/acme/pinkorca.de/key.pem";
        tls_cert_path = "/var/lib/acme/pinkorca.de/cert.pem";
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
            randomizeClientPort = true; # direct connection opnsense?
            # hosts = {
            #
            # };
            groups = {
              "group:trusted" = [
                "Jona"
                "Noah"
                "Rahel"
                "Sofie"
                "Anton"
                "Johannes"
                "Niklas"
                "Aaron"
                "Ulli"
              ];
              "group:vpn" = [
                "Jona"
                "Sofie"
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
                  "Infra"
                ];
                dst = [
                  "Infra:*"
                ];
              }
              {
                action = "accept";
                src = [
                  "group:trusted"
                ];
                dst = [
                  "Infra:*"
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

    environment.systemPackages = [pkgs-unstable.headscale];

    sops.secrets."porkbun/api-key" = {};
    sops.secrets."porkbun/secret-api-key" = {};

    users.users.headscale.extraGroups = ["acme"];

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "dev@pinkorca.de";
        dnsProvider = "porkbun";
        reloadServices = ["headscale"];
        credentialFiles = {
          "PORKBUN_API_KEY_FILE" = config.sops.secrets."porkbun/api-key".path;
          "PORKBUN_SECRET_API_KEY_FILE" = config.sops.secrets."porkbun/secret-api-key".path;
        };
      };
      certs."pinkorca.de".extraDomainNames = [
        "headscale.pinkorca.de"
        "*.ts.pinkorca.de"
      ];
    };
  };
}
