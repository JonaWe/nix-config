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
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
      extraCommands = lib.mkIf cfg.exitNode ''
        iptables -A FORWARD -i tailscale0 -j ACCEPT
        iptables -A FORWARD -o tailscale0 -j ACCEPT
      '';
    };

    environment.systemPackages = [config.services.tailscale.package];
  };
}
