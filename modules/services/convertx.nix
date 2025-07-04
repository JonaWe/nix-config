{
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.convertx;
in {
  options.myconf.services.convertx = {
    enable = lib.mkEnableOption "Enable convertx service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9264;
      example = 9264;
      description = "Port that is used for convertx";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/convertx";
      example = "/var/lib/convertx";
      description = "Base directory that is used to store convertx-server data";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."convertx" = {
      image = "ghcr.io/c4illin/convertx";
      environment = {
        "ALLOW_UNAUTHENTICATED" = "true";
        "ACCOUNT_REGISTRATION" = "true";
        "HTTP_ALLOWED" = "true";
        # TODO: this secret is not important
        "JWT_SECRET" = "a41800bc-d6eb-4d8d-9fc6-ea89a321c840";
      };
      ports = [
        "${toString cfg.port}:3000"
      ];
      volumes = [
        "${cfg.dataDir}:/app/data:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--pull=always"
      ];
    };

    services.nginx.virtualHosts."convert.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
      };
    };
  };
}
