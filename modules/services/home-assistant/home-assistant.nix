{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  # allow mDNS through the firewall
  networking.firewall.allowedUDPPorts = [5353];

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
      "/opt/services/home-assistant/config" = "zdata/enc/services/home-assistant/config";
    };
  };
}
