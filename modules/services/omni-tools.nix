{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.omni-tools;
in {
  options.myconf.services.omni-tools = {
    enable = lib.mkEnableOption "Enable omni-tools service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9281;
      example = 9281;
      description = "Port that is used for omni-tools";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."omni-tools" = {
      image = "iib0011/omni-tools:latest";
      ports = [
        "${toString cfg.port}:80"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."tools.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
