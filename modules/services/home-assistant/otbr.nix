{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  config = lib.mkIf config.homelab.enable {
    # allow ip forwarding
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 0;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    networking.firewall.trustedInterfaces = ["wpan0"];

    users.users.otbr.extraGroups = ["dialout"];

    homelab.services.otbr = {
      port = 8062;
      containerFile = ./otbr.container;

      user = "otbr";
      group = "otbr";

      zfsMounts = {
        "/opt/services/otbr/config" = "zdata/enc/services/otbr/config";
      };
    };
  };
}
