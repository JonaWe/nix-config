{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  # usb dongle permissions
  users.users.zigbee2mqtt.extraGroups = ["dialout"];

  homelab.services.zigbee2mqtt = {
    port = 8929;
    containerFile = ./zigbee2mqtt.container;

    user = "zigbee2mqtt";
    group = "zigbee2mqtt";

    nginx = {
      enable = true;
      domain = "z2m.ts.pinkorca.de";
      websockets = true;
    };

    zfsMounts = {
      "/opt/services/zigbee2mqtt/config" = "zdata/enc/services/zigbee2mqtt/config";
    };
  };
}
