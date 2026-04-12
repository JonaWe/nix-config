{
  config,
  pkgs,
  ...
}: {
  imports = [../homelab.nix];

  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allows software to find 'ant.local'
    nssmdns6 = true; # CRITICAL for Matter (IPv6)
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
    # Ensure it opens the firewall port 5353 automatically
    openFirewall = true;
  };
  networking.interfaces.enp5s0.ipv6.routes = [
    {
      address = "ff00::";
      prefixLength = 8;
    }
  ];
  networking.interfaces.enp4s0.useDHCP = false;
  networking.interfaces.enp4s0.ipv4.addresses = [];
  networking.interfaces.enp4s0.ipv6.addresses = [];
  # the motherboard interface needs to be disabled as the matter server otherwise tries to use it
  networking.localCommands = ''
    ip link set enp4s0 down
  '';
  networking.interfaces.enp5s0.useDHCP = true;
  networking.firewall.allowedUDPPorts = [5353 5683 5540];
  networking.firewall.allowedTCPPorts = [5580 5540];

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [
  #     5580 # Matter Server
  #   ];
  #   allowedUDPPorts = [
  #     5353 # mDNS (CRITICAL for Matter/Thread discovery)
  #     5683 # CoAP (Used by Thread devices)
  #   ];
  #   # Matter uses dynamic ports for commissioning,
  # so we allow the mDNS range specifically:
  # extraCommands = ''
  #   ip6tables -A INPUT -p udp --dport 5353 -j ACCEPT
  #   iptables -A INPUT -p udp --dport 5353 -j ACCEPT
  # '';
  # };
  homelab.services.matter = {
    port = 5580;
    containerFile = ./matter.container;

    user = "matter";
    group = "matter";

    zfsMounts = {
      "/opt/services/matter/config" = "zdata/enc/services/matter/config";
    };
  };
}
