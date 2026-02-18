{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.authentik;
in {
  options.myconf.services.authentik = {
    enable = lib.mkEnableOption "Enable authentik service";
    # port = lib.mkOption {
    #   type = lib.types.port;
    #   default = 9999;
    #   authentik = 9999;
    #   description = "Opens ports for authentik service";
    # };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."authentik/env" = {};
    # sops.secrets."authentik/ldap/env" = {};

    services.authentik = {
      enable = true;
      environmentFile = config.sops.secrets."authentik/env".path;
      settings = {
        # email = {
        #   host = "smtp.example.com";
        #   port = 587;
        #   username = "authentik@example.com";
        #   use_tls = true;
        #   use_ssl = false;
        #   from = "authentik@example.com";
        # };
        disable_startup_analytics = true;
        avatars = "initials";
      };
      nginx = {
        enable = true;
        enableACME = true;
        # useACMEHost = "auth.pinkorca.de";
        host = "auth.pinkorca.de";
      };
    };

    services.authentik-ldap = {
      enable = true;
      # environmentFile = config.sops.secrets."authentik/env".path;
      # AUTHENTIK_TOKEN=<token from authentik for this outpost>
    };
  };
}
