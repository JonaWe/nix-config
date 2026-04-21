{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.convertx = {
    containerFile = ./convertx.container;

    user = "convertx";
    group = "convertx";

    port = 8317;

    nginx = {
      enable = true;
      domain = "convert.ts.pinkorca.de";
    };

    zfsMounts = {
      "/opt/services/convertx/config" = {
        dataset = "zdata/enc/services/convertx/config";
        snapshot = true;
        backup = false;
      };
    };
  };
}
