{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  homelab.services.mosquitto = {
    port = 1883;
    containerFile = ./mosquitto.container;

    user = "mosquitto";
    group = "mosquitto";

    zfsMounts = {
      "/opt/services/mosquitto/config" = "zdata/enc/services/mosquitto/config";
      "/opt/services/mosquitto/data" = "zdata/enc/services/mosquitto/data";
      "/opt/services/mosquitto/log" = "zdata/enc/services/mosquitto/log";
    };
  };
}
