{config, ...}: {
  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = ["video" "render"];
  };
  users.groups.immich = {};

  services.immich = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/data/media/immich";
    user = "immich";
    group = "immich";
    settings.server.externalDomain = "https://photos.home.pinkorca.de";
    environment = {
      IMMICH_ENV = "production";
      IMMICH_LOG_LEVEL = "log";
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/media/immich 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
  ];

  services.nginx.virtualHosts."photos.home.pinkorca.de" = {
    useACMEHost = "pinkorca.de";
    forceSSL = true;
    locations."/" = {
      proxyPass = "${builtins.toString config.services.immich.host}:${builtins.toString config.services.immich.port}/";
    };
  };
}
