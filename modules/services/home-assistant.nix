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
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/home-assistant";
      example = "/var/lib/home-assistant";
      description = "Directory used to store the config";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [8123];
    # if cfg.openFirewall
    # then [cfg.port]
    # else [];

    users.users.home-assistant = {
      isSystemUser = true;
      group = "home-assistant";
    };
    users.groups.home-assistant = {};

    virtualisation.oci-containers.containers."homeassistant" = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      environment = {
        "TZ" = "Europe/Berlin";
      };
      volumes = [
        "${cfg.directory}:/config"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
        "--network=host"
      ];
      # user = "home-assistant:home-assistant";
    };
    # virtualisation.oci-containers.containers."home-assistant" = {
    #   # volumes = ["home-assistant:/config"];
    #   volumes = [
    #     "${cfg.directory}:/config"
    #   ];
    #   environment.TZ = "Europe/Berlin";
    #   image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
    #   # ports = ["${builtins.toString cfg.port}:8123"];
    #   user = "home-assistant:home-assistant";
    #   extraOptions = [
    #     "--network=host"
    #     # "--device=/dev/ttyACM0:/dev/ttyACM0" # Example, change this to match your own hardware
    #   ];
    # };

    services.nginx.virtualHosts."homeassistant.ts.pinkorca.de" = {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/home-assistant" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 home-assistant home-assistant -"
    ];
    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/home-assistant".useTemplate = ["default"];
      };
    };
  };
}
