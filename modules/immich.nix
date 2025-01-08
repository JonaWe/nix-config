{config, ...}: {
  users.users.immich = {
    isSystemUser = true;
    group = "immich";
    extraGroups = ["video" "render"];
  };
  users.groups.immich = {};

  services.immich = {
    enable = true;
    # openFirewall = true;
    host = "192.168.188.133";
    port = 3000;
    user = "immich";
    group = "immich";
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  systemd.tmpfiles.rules = [
    "d /data/media/immich 0700 ${toString config.services.immich.user} ${toString config.services.immich.group} -"
  ];
}
