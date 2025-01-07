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
    # openFireWall = true;
    port = 2283;
    user = "immich";
    group = "immich";
  };

  networking.firewall.allowedTCPPorts = [ 2283 ];

  systemd.tmpfiles.rules = [
    "d /data/media/immich 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
  ];
}
