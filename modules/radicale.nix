{...}: let
  path = "/data/samba/radicale";
in {
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = ["0.0.0.0:5232"];
      storage.filesystem_folder = "${path}/collections";
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${path}/users";
        htpasswd_encryption = "plain";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [5232];

  systemd.tmpfiles.rules = [
    "d ${path} 0700 radicale radicale -"
    "d ${path}/collections 0700 radicale radicale -"
  ];

  # services.nginx.virtualHosts."cal.home.pinkorca.de" = {
  #   useACMEHost = "pinkorca.de";
  #   forceSSL = true;
  #   locations."/" = {
  #     proxyPass = "0.0.0.0:5232/";
  #   };
  # };
}
