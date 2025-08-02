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
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      # useRoutingFeatures = "both";
      # extraUpFlags = [
      #   "--advertise-exit-node"
      # ];
    };
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };

    environment.systemPackages = [config.services.tailscale.package];
  };
}
