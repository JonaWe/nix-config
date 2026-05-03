{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    networking.firewall.interfaces."enp5s0".allowedTCPPorts = [6053 3232];
    networking.firewall.interfaces."enp5s0".allowedUDPPorts = [5353];

    homelab.services.esphome = {
      containerFile = ./esphome.container;

      port = 6052;

      nginx = {
        enable = true;
        domain = "esphome.ts.pinkorca.de";
        websockets = true;
      };

      user = "esphome";
      group = "esphome";

      zfsMounts = {
        "/opt/services/esphome/config" = {
          dataset = "zdata/enc/services/esphome/config";
          snapshot = true;
          backup = true;
        };
      };
    };
  };
}
