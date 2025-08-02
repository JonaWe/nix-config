{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.it-tools;
in {
  options.myconf.services.it-tools = {
    enable = lib.mkEnableOption "Enable it-tools service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9210;
      example = 9210;
      description = "Port that is used for it-tools";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/it-tools";
      example = "/var/lib/it-tools";
      description = "Base directory that is used to store it-tools data";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."it-tools" = {
      image = "corentinth/it-tools";
      environment = {
        "TZ" = "Europe/Berlin";
      };
      ports = [
        "${toString cfg.port}:80"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."it-tools.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
