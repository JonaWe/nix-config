{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  users.users.home-assistant = {
    isNormalUser = true;
    home = "/var/lib/home-assistant/";
    group = "home-assistant";
    description = "User for the arr apps";
    linger = true;
  };
  users.groups.home-assistant = {
  };




  # networking.firewall.allowedTCPPorts = [8096];
  # auto discovery
  # networking.firewall.allowedUDPPorts = [7359];

  homelab.services.home-assistant = {
    port = 8096;
    nginx = {
      enable = true;
      domain = "hass.ts.pinkorca.de";
      websockets = true;
      # extraConfig = ''
      #   proxy_buffering off;
      # '';
    };
    containerFile = ./home-assistant.container;
    # user = "arr";
    # group = "arr";
    zfsMounts = {
      "/opt/services/home-assistant/config" = "zdata/enc/services/home-assistant/config";
      "/opt/services/jellyfin/cache" = "zdata/enc/services/jellyfin3/cache";
    };
  };
}
