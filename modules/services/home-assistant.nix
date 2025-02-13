{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.home-assistant;
in {
  options.myconf.services.home-assistant = {
    enable = lib.mkEnableOption "Enable home assistant service for smart home automation";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for home assistant service";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 8123;
      example = 8123;
      description = "The port that is exposed to the host network";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [8123];
    # if cfg.openFirewall
    # then [cfg.port]
    # else [];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.homeassistant = {
        volumes = ["home-assistant:/config"];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
        ports = ["${builtins.toString cfg.port}:8123"];
        extraOptions = [
          "--network=host"
          # "--device=/dev/ttyACM0:/dev/ttyACM0" # Example, change this to match your own hardware
        ];
      };
    };
  };
}
