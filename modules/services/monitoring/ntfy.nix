{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  environment.etc."monitoring/ntfy/server.yml" = {
    source = ./config/ntfy/server.yml;
    mode = "0444";
  };

  environment.etc."monitoring/ntfy/templates/homelab.yml" = {
    source = ./config/ntfy/templates/homelab.yml;
    mode = "0444";
  };

  homelab.services.ntfy = {
    containerFile = ./ntfy.container;
    rootless = true;

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
      "/opt/services/ntfy/cache" = {
        dataset = "zdata/enc/services/ntfy/cache";
        snapshot = true;
        backup = false;
      };
    };
  };
}
