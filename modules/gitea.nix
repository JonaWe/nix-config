{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.gitea;
in {
  # options.networking = {
  #   domain = lib.mkOption {
  #     type = lib.types.str;
  #     default = "example.com";
  #     description = "base domain";
  #   };
  # };
  config = {
    # networking.domain = "pinkorca.de";

    services.gitea = rec {
      enable = true;
      user = "git";
      appName = "Gitea";
      # disableRegistration = true;
      stateDir = "/srv/gitea";
      repositoryRoot = "${stateDir}/repositories";
      database = {
        #   type = "sqlite3";
        user = "git";
        #   path = "${stateDir}/gitea.db";
      };
      # enableUnixSocket = true;
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
        server = {
          HTTP_PORT = 3002;
          ROOT_URL = "http://192.168.188.133:3002/";
          DOMAIN = "http://192.168.188.133:3002/";
          SSH_USER = "git";
          SSH_DOMAIN = "192.168.188.133";
          #     SSH_TRUSTED_USER_CA_KEYS = lib.concatStringsSep "," [
          #       (builtins.readFile "${inputs.ssh}/ca.pub")
          #     ];
          #     OFFLINE_MODE = true;
        };
      };
    };

    users.users.git = {
      isSystemUser = true;
      useDefaultShell = true;
      group = "git";
      extraGroups = ["gitea"];
      home = cfg.stateDir;
    };
    users.groups.git = {};

    # services.nginx.upstreams.gitea = with config.services.gitea;
    #   lib.mkIf enable {
    #     servers = {
    #       "unix:${config.services.gitea.settings.server.HTTP_ADDR}" = {};
    #     };
    #   };
    #   services.nginx.virtualHosts."git.${config.services.gitea.domain}" = {
    #     forceSSL = true;
    #     useACMEHost = "home.pinkorca.de";
    #     locations."/".proxyPass = "http://gitea";
    #   };
    # };
    #
    networking.firewall.allowedTCPPorts = [3002];

    # services.nginx.virtualHosts."git.home.pinkorca.de" = {
    #   useACMEHost = "pinkorca.de";
    #   addSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://0.0.0.0:3002/";
    #   };
    # };
  };
}
