{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.myconf.services.searx;
in {
  options.myconf.services.searx = {
    enable = lib.mkEnableOption "Enable searx service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9301;
      example = 9301;
      description = "Port for searx service";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/searx";
      description = "Directory used for searx service";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."searx/environment" = {};

    services.searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = config.sops.secrets."searx/environment".path;
      settings = {
        server = {
          bind_address = "127.0.0.1";
          port = cfg.port;
          # WARNING: setting secret_key here might expose it to the nix cache
          # see below for the sops or environment file instructions to prevent this
          secret_key = "Your secret key.";
        };
        enabled_plugins = [
          "Basic Calculator"
          "Hash plugin"
          "Tor check plugin"
          "Open Access DOI rewrite"
          "Hostnames plugin"
          "Unit converter plugin"
          "Tracker URL remover"
        ];
        # Instance settings
        general = {
          debug = false;
          instance_name = "SearXNG Search";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        # User interface
        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = false;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = false;
          hotkeys = "vim";
        };

        # Search engine settings
        search = {
          safe_search = 2;
          autocomplete_min = 2;
          autocomplete = "duckduckgo";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
        };
      };
    };

    services.nginx.virtualHosts."search.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/searx" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 searx searx -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/searx".useTemplate = ["default"];
      };
    };
  };
}
