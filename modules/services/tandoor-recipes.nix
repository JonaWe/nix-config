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
    backupDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/data/postgresql/backups";
      description = "Directory used for sql dump backups";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
      package = pkgs-unstable.tandoor-recipes;
      port = 9203;
      extraConfig = let
        tandoorRecipesDomain = "recipes.ts.pinkorca.de";
      in {
        # Use PostgreSQL
        DB_ENGINE = "django.db.backends.postgresql";
        POSTGRES_HOST = "/run/postgresql";
        POSTGRES_USER = "tandoor_recipes";
        POSTGRES_DB = "tandoor_recipes";

        ENABLE_METRICS = "1";
        ENABLE_SIGNUP = "1";

        # Security settings
        ALLOWED_HOSTS = "${tandoorRecipesDomain},localhost";
        CSRF_TRUSTED_ORIGINS = "https://${tandoorRecipesDomain}";

        # Misc
        TIMEZONE = "Europe/Berlin";
      };
    };

    sops.secrets."tandoor/environment" = {};

    systemd.services = {
      tandoor-recipes = {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];

        serviceConfig = {
          EnvironmentFile = config.sops.secrets."tandoor/environment".path;
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
    services.postgresqlBackup = {
      enable = true;
      databases = ["tandoor_recipes"];
      startAt = "*-*-* *:55:00";
      location = cfg.backupDirectory;
    };

    systemd.services.nginx.serviceConfig.SupplimentaryGroups = ["tandoor_recipes"];

    users.users.tandoor_recipes = {
      isSystemUser = true;
      group = "tandoor_recipes";
    };
    users.groups.tandoor_recipes = {};

    services.nginx.virtualHosts."recipes.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      kTLS = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9203";
      };
      locations."/media/recipes/".alias = "/var/lib/tandoor-recipes/recipes/";
      locations."= /metrics" = {
        return = "404";
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/postgresqlBackups" = {
        type = "zfs_fs";
        mountpoint = cfg.backupDirectory;
        options.mountpoint = "legacy";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.backupDirectory} 0700 postgres postgres -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/postgresqlBackups".useTemplate = ["default"];
      };
    };
  };
}
