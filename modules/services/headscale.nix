{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.headscale;
in {
  options.myconf.services.headscale = {
    enable = lib.mkEnableOption "Enable headscale service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8089;
      example = 8089;
      description = "Port that is used for headscale";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/headscale";
      example = "/var/lib/headscale";
      description = "Base directory that is used to store headscale data";
    };
    user = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "headscale";
        description = "User that is used to run headscale";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 2020;
        description = "User id that is used to run headscale";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 2020;
        description = "Group id that is used to run headscale";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "grocy";
        description = "Group that is used to run headscale";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # users.users.${cfg.user.user} = {
    #   isNormalUser = true;
    #   home = cfg.dataDir;
    #   group = cfg.user.group;
    #   description = "User for the grocy";
    #   uid = cfg.user.uid;
    # };
    #
    # users.groups.${cfg.user.group} = {
    #   gid = cfg.user.gid;
    # };
    # virtualisation.oci-containers.containers."grocy" = {
    #   image = "lscr.io/linuxserver/grocy:latest";
    #   environment = {
    #     "PGID" = toString cfg.user.gid;
    #     "PUID" = toString cfg.user.uid;
    #     "TZ" = "Europe/Berlin";
    #   };
    #   ports = [
    #     "${toString cfg.port}:80"
    #   ];
    #   volumes = [
    #     "${cfg.dataDir}:/config:rw"
    #   ];
    #   log-driver = "journald";
    #   extraOptions = [
    #     "--pull=always"
    #   ];
    # };
    services.headscale = {
      enable = true;
      port = cfg.port;
      address = "0.0.0.0";
      settings = {
        server_url = "https://headscale.pinkorca.de";
        logtail.enabled = false;
        dns = {
          base_domain = "head.scale";
        };
      };
      # package = pkgs.headscale;
    };

    services.tailscale.enable = true;
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };

    environment.systemPackages = [config.services.headscale.package];

    # environment.systemPackages = [pkgs.headscale];

    services.nginx.virtualHosts."headscale.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
}
