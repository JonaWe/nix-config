{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    services.nginx.virtualHosts."nextcloud.ts.pinkorca.de" = {
      locations."^~ /.well-known/carddav".return = "301 $scheme://$host/remote.php/dav";
      locations."^~ /.well-known/caldav".return = "301 $scheme://$host/remote.php/dav";
    };

    homelab.services.nextcloud = {
      port = 8052;
      containerFile = ./nextcloud.container;

      user = "nextcloud";
      group = "nextcloud";

      nginx = {
        enable = true;
        domain = "nextcloud.ts.pinkorca.de";
        websockets = true;
      };

      zfsMounts = {
        "/opt/services/nextcloud/data" = {
          dataset = "zdata/enc/services/nextcloud/data";
          snapshot = true;
          backup = true;
        };
      };
    };
  };
}
