{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.ntfy;
in {
  options.myconf.services.ntfy = {
    enable = lib.mkEnableOption "Enable ntfy service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 2586;
      example = 2586;
      description = "Port used for the local ntfy service to listen on";
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ntfy-sh";
      description = "Directory used for ntfy cache and attachments";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":${toString cfg.port}";
        base-url = "https://ntfy.ts.pinkorca.de";
        cache-file = "${cfg.directory}/cache.db";
        attachment-cache-dir = "${cfg.directory}/attachments";
      };
    };

    services.nginx.virtualHosts."ntfy.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";

        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_redirect off;

          proxy_connect_timeout 3m;
          proxy_send_timeout 3m;
          proxy_read_timeout 3m;

          client_max_body_size 0;
        '';
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 ntfy-sh ntfy-sh -"
      "d ${cfg.directory}/attachments 0700 ntfy-sh ntfy-sh -"
    ];
  };
}
