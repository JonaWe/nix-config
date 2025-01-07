{config, ...}: {
  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = ["video" "render"];
  };
  users.groups.immich = {};

  users.groups.samba-data = {};
  services.immich = {
    enable = true;
    openFirewall = true;
    user = "immich";
    group = "immich";
  };

  systemd.tmpfiles.rules = [
    "d /data/media/immich 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
  ];
}
