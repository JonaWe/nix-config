{
  config,
  lib,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    homelab.services.bambuddy = {
      port = 8010;
      containerFile = ./bambuddy.container;
      rootless = true;

      user = "bambuddy";
      group = "bambuddy";

      nginx = {
        enable = true;
        domain = "bambuddy.ts.pinkorca.de";
        websockets = true;
      };

      zfsMounts = {
        "/opt/services/bambuddy/data" = {
          dataset = "zdata/enc/services/bambuddy/data";
          snapshot = true;
          backup = true;
        };
        "/opt/services/bambuddy/logs" = {
          dataset = "zdata/enc/services/bambuddy/logs";
          snapshot = true;
          backup = false;
        };
      };
    };
  };
}
