{
  pkgs,
  config,
  ...
}: {
  sops.secrets."wireguard/configs/wg-laptop.conf" = {};
  sops.secrets."wireguard/configs/wg-homelab-laptop.conf" = {};
  networking.wg-quick.interfaces = {
    wg-homelab = {
      configFile = config.sops.secrets."wireguard/configs/wg-homelab-laptop.conf".path;
      autostart = false;
    };
    wg0 = {
      configFile = config.sops.secrets."wireguard/configs/wg-laptop.conf".path;
      autostart = false;
    };
  };
  # networking.wg-quick.interfaces."wg-home" = {
  #   autostart = true;
  #   dns = ["192.168.188.1" "fritz.box"];
  #   privateKeyFile = config.sops.secrets."wireguard/privatehome".path;
  #   address = ["192.168.188.203/24"];
  #   # listenPort = 51820;
  #
  #   peers = [
  #     {
  #       publicKey = "lxWt1sm9n/UNpcX6yMc1bXZ9P5c0JX2egrjtVSzk7SU=";
  #       allowedIPs = ["192.168.188.0/24" "0.0.0.0/0"];
  #       endpoint = "home.pinkorca.de:57031";
  #         persistentKeepalive = 25;
  #     }
  #   ];
  # };
  networking.firewall = {
    allowedUDPPorts = [57031];
  };
  # networking.wireguard.enable = true;
  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = ["10.100.0.2/24"];
  #     listenPort = 51820;
  #     privateKeyFile = config.sops.secrets."wireguard/private".path;
  #
  #     peers = [
  #       {
  #         publicKey = "6BGuu4h4uJTMyN0+npEzZObz1KhXc7fweqz6yYo6YTE=";
  #
  #         # Forward all the traffic via VPN.
  #         allowedIPs = ["0.0.0.0/0"];
  #         # Or forward only particular subnets
  #         # allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];
  #
  #         # Set this to the server IP and port.
  #         endpoint = "home.pinkorca.de:51820";
  #
  #         # Send keepalives every 25 seconds. Important to keep NAT tables alive.
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #   };
  # };
}
