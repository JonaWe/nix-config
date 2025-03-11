{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.tandoor-recipes;
in {
  options.myconf.services.tandoor-recipes = {
    enable = lib.mkEnableOption "Enable tandoor-recipes service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Opens ports for tandoor-recipes";
    };
    # baseDirectory = lib.mkOption {
    #   type = lib.types.str;
    #   default = "/data/media/gitea";
    #   description = "Directory used for gitea data";
    # };
    # repoDirectory = lib.mkOption {
    #   type = lib.types.str;
    #   default = "${cfg.baseDirectory}/repo";
    #   description = "Directory used for gitea repo data";
    # };
    # zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    # zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    # services.postgresql = {
    #   enable = true;
    #   ensureUsers = [
    #     {
    #       name = "tandoor_recipes";
    #       ensureDBOwnership = true;
    #     }
    #   ];
    #   ensureDatabases = [
    #     "tandoor_recipes"
    #   ];
    # };
    # services.tandoor-recipes = {
    #   enable = true;
    #   port = 9203;
    #   package = pkgs-unstable.tandoor-recipes;
    #   extraConfig = let
    #     tandoorRecipesDomain = "recipes.home.pinkorca.de";
    #   in {
    #     # DB_ENGINE = "django.db.backends.postgresql";
    #     # POSTGRES_DB = "tandoor_recipes";
    #     # Use PostgreSQL
    #     # DB_ENGINE = "django.db.backends.postgresql";
    #     # POSTGRES_HOST = "/run/postgresql";
    #     # POSTGRES_USER = "tandoor_recipes";
    #     # POSTGRES_DB = "tandoor_recipes";
    #     ENABLE_SIGNUP= "1";
    #
    #     # GUNICORN_MEDIA = "0";
    #     # MEDIA_URL="/data/media/"
    #
    #     # Security settings
    #     # ALLOWED_HOSTS = tandoorRecipesDomain;
    #     # CSRF_TRUSTED_ORIGINS = "https://${tandoorRecipesDomain}";
    #     #
    #     # # Misc
    #     # TIMEZONE = "Europe/Berlin";
    #   };
    # };

    services.tandoor-recipes = {
      enable = true;
      package = pkgs-unstable.tandoor-recipes;
      port = 9203;
      extraConfig = let
        tandoorRecipesDomain = "recipes.home.pinkorca.de";
      in {
        # Use PostgreSQL
        DB_ENGINE = "django.db.backends.postgresql";
        POSTGRES_HOST = "/run/postgresql";
        POSTGRES_USER = "tandoor_recipes";
        POSTGRES_DB = "tandoor_recipes";

        ENABLE_SIGNUP= "1";

        # Security settings
        ALLOWED_HOSTS = tandoorRecipesDomain;
        CSRF_TRUSTED_ORIGINS = "https://${tandoorRecipesDomain}";

        # Misc
        TIMEZONE = "Europe/Berlin";
      };
    };

    systemd.services = {
      tandoor-recipes = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];

        serviceConfig = {
          # EnvironmentFile = cfg.secretKeyFile;
          DynamicUser = lib.mkForce false;
        };
      };
    };

    # Set-up database
    services.postgresql = {
      enable = true;
      ensureDatabases = ["tandoor_recipes"];
      ensureUsers = [
        {
          name = "tandoor_recipes";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.nginx.serviceConfig.SupplimentaryGroups = ["tandoor_recipes"];

    users.users.tandoor_recipes = {
      isSystemUser = true;
      group = "tandoor_recipes";
    };
    users.groups.tandoor_recipes = {};

    ### Ingress
    services.nginx.virtualHosts."recipes.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      # locations."/media/".alias = "/var/lib/tandoor-recipes/"; # needed to show images
      # locations."^~ /" = {
      #   proxyPass = "http://127.0.0.1:9203";
      #   # extraConfig = "resolver 10.88.0.1;";
      # };
      kTLS = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9203";
      };
      locations."/media/recipes/".alias = "/var/lib/tandoor-recipes/recipes/";
      locations."= /metrics" = {
        return = "404";
      };
    };

    # services.mealie.port = 9202;
    # services.mealie.enable = true;
    # services.nginx.virtualHosts."mealie.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
    #   useACMEHost = "pinkorca.de";
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:9202/";
    #   };
    # };
  };
}
