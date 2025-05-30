{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.myconf.services.jellyfin;
in {
  options.myconf.services.jellyfin = {
    enable = lib.mkEnableOption "Enable jellyfin service for media streaming";
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellyfin";
      description = "Directory used for jellyfin storage";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for jellyfin service";
    };
    mediaDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/data/media/jellyfin";
      description = "Directory used for media files";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin";
      description = "User used for jellyfin service";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin";
      description = "Group used for jellyfin service";
    };
    zfsIntegration.enable = lib.mkEnableOption "Enable zfs integration that creates datasets etc.";
    zfsIntegration.enableBackups = lib.mkEnableOption "Enables zfs backups for the created datasets";
  };

  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts."jellyfin.winkelsheim.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8096/";
      };
    };
    services.nginx.virtualHosts."jellyfin.home.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8096/";
      };
    };
    services.nginx.virtualHosts."jellyfin.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8096/";
      };
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        intel-compute-runtime
        intel-media-sdk
      ];
    };

    nixpkgs.overlays = [
      (
        final: prev: {
          jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall

              # this is the important line
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web

              runHook postInstall
            '';
          });
        }
      )
    ];

    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];

    services.jellyfin = {
      enable = true;
      openFirewall = cfg.openFirewall;
      user = cfg.user;
      group = cfg.group;
      dataDir = cfg.directory;
      cacheDir = "${cfg.directory}/cache";
    };

    myconf.disk.dataPool.extraDatasets = lib.mkIf cfg.zfsIntegration.enable {
      "enc/services/jellyfin" = {
        type = "zfs_fs";
        mountpoint = cfg.directory;
        options.mountpoint = "legacy";
      };
      "enc/services/jellyfin/media" = {
        type = "zfs_fs";
        mountpoint = cfg.mediaDirectory;
        options.mountpoint = "legacy";
        options.quota = "5T";
        options.recordsize = "1M";
      };
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.zfsIntegration.enable [
      "d ${cfg.directory} 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.mediaDirectory} 0700 ${cfg.user} ${cfg.group} -"
    ];

    services.sanoid = lib.mkIf cfg.zfsIntegration.enableBackups {
      datasets = {
        "zdata/enc/services/jellyfin".useTemplate = ["default"];
      };
    };
  };
}
