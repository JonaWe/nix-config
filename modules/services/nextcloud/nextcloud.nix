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
      rootless = true;

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

    # keep-id maps the container's apache onto the host's nextcloud user, so
    # peer auth on the local socket lands on the role of the same name.
    services.postgresql = {
      enable = true;
      ensureDatabases = ["nextcloud"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    # location and startAt stay with tandoor-recipes; databases merges.
    services.postgresqlBackup = {
      enable = true;
      databases = ["nextcloud"];
    };
  };
}
