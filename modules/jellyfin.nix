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
  };

  config = lib.mkIf cfg.enable {
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
      openFirewall = true;
      dataDir = "/data/media/jellyfin";
      cacheDir = "/data/media/jellyfin/cache";
    };

    systemd.tmpfiles.rules = [
      "d /data/media/jellyfin 0700 jellyfin jellyfin -"
    ];
  };
}
