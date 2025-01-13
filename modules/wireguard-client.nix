{
  pkgs,
  config,
  ...
}: {
  sops.secrets."wireguard/private" = {};
  networking.firewall = {
    allowedUDPPorts = [51820];
  };
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.100.0.2/24"];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wireguard/private".path;

      peers = [
        {
          publicKey = "6BGuu4h4uJTMyN0+npEzZObz1KhXc7fweqz6yYo6YTE=";

          # Forward all the traffic via VPN.
          allowedIPs = ["0.0.0.0/0"];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          # endpoint = "home.pinkorca.de:51820";
          endpoint = "2.241.79.146:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
