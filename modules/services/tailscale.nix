{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myconf.services.tailscale;
in {
  options.myconf.services.tailscale = {
    enable = lib.mkEnableOption "Enable headscale tailscale";
    exitNode = lib.mkEnableOption "Enable exit node routing features";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkIf cfg.exitNode "server";
    };
    networking.firewall = {
      checkReversePath = if cfg.exitNode then false else "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
      extraCommands = lib.mkIf cfg.exitNode ''
        iptables -I FORWARD -i tailscale0 -j ACCEPT
        iptables -I FORWARD -o tailscale0 -j ACCEPT
        iptables -t nat -I POSTROUTING -s 100.64.0.0/10 -o tailscale0 -j RETURN
        iptables -t nat -I POSTROUTING -s 100.64.0.0/10 ! -o tailscale0 -j MASQUERADE
      '';
    };

    boot.kernel.sysctl = lib.mkIf cfg.exitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    environment.systemPackages = [config.services.tailscale.package];
  };
}
