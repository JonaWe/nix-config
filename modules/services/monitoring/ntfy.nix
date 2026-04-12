{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.ntfy = {
    containerFile = ./ntfy.container;

    user = "ntfy";
    group = "ntfy";

    port = 8019;
    openFirewall = true;

    nginx = {
      enable = true;
      domain = "ntfy.ts.pinkorca.de";
      websockets = true;
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

    zfsMounts = {
      "/opt/services/ntfy/config" = "zdata/enc/services/ntfy/config";
      "/opt/services/ntfy/cache" = "zdata/enc/services/ntfy/cache";
    };
  };
}
