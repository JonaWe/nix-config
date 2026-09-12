{
  config,
  lib,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    # Rootless podman on the host netns cannot bind below 1024 even with
    # NET_BIND_SERVICE; the capability sits in the wrong user namespace.
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 322;

    networking.firewall = {
      allowedTCPPorts = [322 990 3000 3002 6000 8883];
      allowedTCPPortRanges = [
        {
          from = 50000;
          to = 50100;
        }
      ];
      allowedUDPPorts = [1900 2021];
    };

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
