{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    fileSystems."/opt/data/media" = {
      device = "/data/media/jellyfin";
      options = ["bind"];
    };

    systemd.tmpfiles.rules = ["d /opt/data/media 0755 arr arr -"];

    networking.firewall.allowedTCPPorts = [8096];
    # auto discovery
    networking.firewall.allowedUDPPorts = [7359];

    homelab.services.jellyfin = {
      port = 8096;
      containerFile = ./jellyfin.container;

      user = "arr";
      group = "arr";
      uid = 2010;
      gid = 2010;

      nginx = {
        enable = true;
        domain = "jellyfin.ts.pinkorca.de";
        websockets = true;
        extraConfig = "proxy_buffering off;";
      };

      zfsMounts = {
        "/opt/services/jellyfin/config" = "zdata/enc/services/jellyfin3/config";
        "/opt/services/jellyfin/cache" = "zdata/enc/services/jellyfin3/cache";
      };
    };
  };
}
