{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/ssh.nix
    ../../modules/sops.nix
  ];
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  myconf.disk = {
    enable = true;
    ext4 = {
      enable = true;
    };
  };

  myconf.services = {
    nginx = {
      enable = true;
      openFirewall = true;
    };
    headscale = {
      enable = true;
      openFirewall = true;
    };
    authentik.enable = true;
    tailscale = {
      enable = true;
      exitNode = true;
    };
  };

  # environment.systemPackages = with pkgs; [
  #   socat
  # ];

  # systemd.services.minecraft-forward = {
  #   description = "Forward Minecraft traffic to home server via Tailscale";
  #   after = ["network-online.target" "tailscale.service"];
  #   wantedBy = ["multi-user.target"];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:25565,reuseaddr,fork TCP:100.64.0.2:25565";
  #     Restart = "always";
  #     RestartSec = 5;
  #   };
  # };
  #
  # networking.firewall.allowedTCPPorts = [25565];

  networking.hostName = "albatross";

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  system.stateVersion = "24.11";
}
