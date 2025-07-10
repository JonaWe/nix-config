{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.olivetin;
in {
  options.myconf.services.olivetin = {
    enable = lib.mkEnableOption "Enable Olive Tin";
  };

  config = lib.mkIf cfg.enable {
    users.users.olivetin = {
      isSystemUser = true;
      group = "olivetin";
      # extraGroups = ["docker"];
    };

    users.groups.olivetin = {};

    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "docker-qbittorrent.service" &&
          subject.user == "olivetin"
        ) {
          return polkit.Result.YES;
        }
      });
    '';

    services.olivetin = {
      enable = true;
      user = "olivetin";
      group = "olivetin";
      settings = {
        listenAddressSingleHTTPFrontend = "localhost:9137";
        actions = [
          {
            title = "Restart qBittorrent";
            icon = "&#128260;"; # 🔄
            shell = "systemctl restart docker-qbittorrent";
          }
        ];
      };
    };

    services.nginx.virtualHosts."olivetin.ts.pinkorca.de" = lib.mkIf config.myconf.services.nginx.enable {
      useACMEHost = "pinkorca.de";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:9137/";
        proxyWebsockets = true;
      };
    };
  };
}
