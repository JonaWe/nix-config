{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];
  homelab.services.jellyfin = {
    port = 8099;
    nginx = {
      enable = true;
      domain = "jellyfin3.ts.pinkorca.de";
      websockets = true;
    };
    containerFile = ./jellyfin.container;
    user = "arr";
    group = "arr";
    zfsMounts = {
      "/opt/services/jellyfin/config" = "zdata/enc/services/jellyfin3/config";
      # "/opt/data/media" = "zdata/enc/services/jellyfin/media";
    };
  };
}
