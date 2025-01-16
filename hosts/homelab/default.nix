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
    ../../modules/docker.nix
    ../../modules/samba.nix
    ../../modules/jellyfin.nix
    ../../modules/fonts.nix
    ../../modules/minecraft-servers.nix
    ../../modules/sops.nix
    ../../modules/ddclient.nix
    ../../modules/gitea.nix
    ../../modules/radicale.nix
    ../../modules/syncthing-homelab.nix
    # ../../modules/immich.nix
    ../../modules/nginx.nix
    # ../../modules/wireguard-server.nix
    ./disko-config.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs" "ntfs"];

  # networking.hostId = "37dff6a3";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  services.sanoid = {
    enable = true;
    templates = {
      default = {
        daily = 7;
        hourly = 23;
        weekly = 4;
        monthly = 3;
      };
    };
    datasets = {
      "zdata/samba".useTemplate = ["default"];
    };
  };

  services.teamspeak3 = {
    enable = true;
    openFirewall = true;
  };

  networking.hostName = "homelab";

  networking.firewall = {
    enable = true;
    allowPing = true;
    # Open ports in the firewall.
    allowedTCPPorts = [3001];
    # allowedUDPPorts = [ ... ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
