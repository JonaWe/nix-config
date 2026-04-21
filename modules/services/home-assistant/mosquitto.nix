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
        "/opt/services/mosquitto/config" = {
          dataset = "zdata/enc/services/mosquitto/config";
          snapshot = true;
          backup = true;
        };
        "/opt/services/mosquitto/data" = {
          dataset = "zdata/enc/services/mosquitto/data";
          snapshot = true;
          backup = true;
        };
        "/opt/services/mosquitto/log" = {
          dataset = "zdata/enc/services/mosquitto/log";
          snapshot = true;
          backup = true;
        };
    };
  };
}
