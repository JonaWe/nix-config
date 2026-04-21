{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    # allow mDNS through the firewall
    networking.firewall.allowedUDPPorts = [5353];
    networking.firewall.allowedTCPPorts = [8123];

    homelab.services.home-assistant = {
      port = 8123;
      containerFile = ./home-assistant.container;

      user = "hass";
      group = "hass";

      nginx = {
        enable = true;
        domain = "hass.ts.pinkorca.de";
        websockets = true;
      };

      zfsMounts = {
        "/opt/services/home-assistant/config" = {
          dataset = "zdata/enc/services/home-assistant/config";
          snapshot = true;
          backup = true;
        };
      };
    };
  };
}
