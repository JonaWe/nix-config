{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.actual = {
    containerFile = ./actual.container;

    user = "actual";
    group = "actual";

    port = 9284;

    nginx = {
      enable = true;
      domain = "actual.ts.pinkorca.de";
    };

    zfsMounts = {
      "/opt/services/actual/config" = {
        dataset = "zdata/enc/services/actual/config";
        snapshot = true;
        backup = true;
      };
    };
  };
}
