{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.paperless-broker = {
    containerFile = ./paperless-broker.container;

    user = "paperless";
    group = "paperless";
    uid = 1315;
    gid = 1315;

    zfsMounts = {
      "/opt/services/paperless/redis" = {
        dataset = "zdata/enc/services/paperless/redis";
        snapshot = false;
        backup = false;
      };
    };
  };

  homelab.services.paperless = {
    containerFile = ./paperless.container;

    user = "paperless";
    group = "paperless";
    uid = 1315;
    gid = 1315;

    port = 8000;

    nginx = {
      enable = true;
      domain = "paperless.ts.pinkorca.de";
    };

    zfsMounts = {
      "/opt/services/paperless/config" = {
        dataset = "zdata/enc/services/paperless/config";
        snapshot = true;
        backup = true;
      };
    };
  };
}