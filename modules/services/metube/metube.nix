{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.metube = {
    containerFile = ./metube.container;

    user = "metube";
    group = "metube";
    uid = 2028;
    gid = 2028;

    port = 9209;

    nginx = {
      enable = true;
      domain = "metube.ts.pinkorca.de";
    };

    zfsMounts = {
      "/opt/services/metube/downloads" = {
        dataset = "zdata/enc/services/metube/downloads";
        snapshot = true;
        backup = false;
      };
    };
  };
}
