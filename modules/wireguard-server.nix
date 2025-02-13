{
  pkgs,
  config,
  ...
}: {
  sops.secrets."wireguard/private" = {};
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    allowedUDPPorts = [51820];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["10.100.0.1/24"];
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      privateKeyFile = config.sops.secrets."wireguard/private".path;

      peers = [
        {
          publicKey = "6BGuu4h4uJTMyN0+npEzZObz1KhXc7fweqz6yYo6YTE=";
          allowedIPs = ["10.100.0.2/32"];
        }
        {
          publicKey = "6BGuu4h4uJTMyN0+npEzZObz1KhXc7fweqz6yYo6YTE=";
          allowedIPs = ["10.100.0.3/32"];
        }
        { # Phone
          publicKey = "HeBxNhME2mobfLf/6bxW5VIS/i4rreD4nmjV9+ADlhs=";
          allowedIPs = ["10.100.0.4/32"];
        }
      ];
    };
  };
}
