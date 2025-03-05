{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.myconf.services.gitea;
in {
  options.myconf.services.gitea = {
    enable = lib.mkEnableOption "Enable gitea service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for gitea";
    };
  };
  config = lib.mkIf cfg.enable {
    services.gitea = rec {
      enable = true;
      user = "git";
      appName = "Gitea";
      stateDir = "/srv/gitea";
      repositoryRoot = "${stateDir}/repositories";
      database = {
        user = "git";
      };
      # ssh = {
      #   clonePort = lib.head config.services.openssh.ports;
      # };
      lfs = {
        enable = true;
        contentDir = "${stateDir}/lfs";
      };
      settings = {
        log.ROOT_PATH = "${stateDir}/log";
        session = {
          COOKIE_SECURE = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          PROTOCOL = "https";
          HTTP_PORT = 3002;
          ROOT_URL = "https://gitea.home.pinkorca.de/";
          DOMAIN = "gitea.home.pinkorca.de";
          SSH_USER = "git";
        };
      };
    };

    users.users.git = {
      isSystemUser = true;
      useDefaultShell = true;
      group = "git";
      extraGroups = ["gitea"];
      home = "/srv/gitea";
    };
    users.groups.git = {};

    services.nginx.virtualHosts."gitea.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3002/";
      };
    };

    services.nginx.upstreams.gitea = {
      servers = {
        "unix:${config.services.gitea.settings.server.HTTP_ADDR}" = {};
      };
    };

    # networking.firewall.allowedTCPPorts = [3002];

    # services.nginx.virtualHosts."git.home.pinkorca.de" = {
    #   useACMEHost = "pinkorca.de";
    #   addSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://0.0.0.0:3002/";
    #   };
    # };
  };
}
