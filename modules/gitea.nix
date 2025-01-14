{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.gitea;
in {
  options.networking = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "base domain";
    };
  };
  config = {
    networking.domain = "pinkorca.de";

    services.gitea = rec {
      enable = true;
      # rootUrl = "https://git.${domain}/";
      # user = "git";
      # appName = "Gitea";
      # disableRegistration = true;
      # inherit (config.networking) domain;
      # stateDir = "/srv/gitea";
      # repositoryRoot = "${stateDir}/repositories";
      # database = {
      #   type = "sqlite3";
      #   inherit user;
      #   path = "${stateDir}/gitea.db";
      # };
      # enableUnixSocket = true;
      # ssh = {
      #   clonePort = lib.head config.services.openssh.ports;
      # };
      # lfs = {
      #   enable = true;
      #   contentDir = "${stateDir}/lfs";
      # };
      # cookieSecure = true;
      # settings = {
      #   server = {
      #     SSH_USER = "git";
      #     SSH_DOMAIN = "git.${domain}";
      #     SSH_TRUSTED_USER_CA_KEYS = lib.concatStringsSep "," [
      #       (builtins.readFile "${inputs.ssh}/ca.pub")
      #     ];
      #     OFFLINE_MODE = true;
      #   };
      # };
      # log.rootPath = "${stateDir}/log";
    };

    # users.users.git = {
    #   isSystemUser = true;
    #   useDefaultShell = true;
    #   group = "git";
    #   extraGroups = ["gitea"];
    #   home = cfg.stateDir;
    # };
    # users.groups.git = {};
    #
    # services.nginx.upstreams.gitea = with config.services.gitea;
    #   lib.mkIf enable {
    #     servers = {
    #       "unix:${config.services.gitea.settings.server.HTTP_ADDR}" = {};
    #     };
    #   };
    # services.nginx.virtualHosts."git.${config.services.gitea.domain}" = {
    #   forceSSL = true;
    #   useACMEHost = config.services.gitea.domain;
    #   locations."/".proxyPass = "http://gitea";
    # };
  };
}
