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
    user = "immich";
    group = "immich";
  };


  systemd.tmpfiles.rules = [
    "d /data/media/immich 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
  ];
}
