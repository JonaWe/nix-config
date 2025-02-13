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
    ../../modules/fonts.nix
    ../../modules/sops.nix
    ../../modules/ddclient.nix
    ../../modules/gitea.nix
    ../../modules/radicale.nix
    ../../modules/nginx.nix
    ../../modules/wireguard-server.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.supportedFilesystems = ["zfs" "ntfs"];

  myconf.disk = {
    enable = true;
    backups.enable = true;
    rootPool = {
      enable = true;
      drive = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0T513845T";
    };
    dataPool = {
      enable = true;
      drives = [
        "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20TJNQ"
        "/dev/disk/by-id/ata-ST16000NM001G-2KK103_ZL2NZAQ8"
        "/dev/disk/by-id/ata-ST16000NM001G-2KK103_WL20VP3M"
      ];
    };
  };

  myconf.services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    teamspeak = {
      enable = true;
      openFirewall = true;
    };
    syncthing = {
      enable = true;
      dataDir = "/data/syncthing";
      user = "syncthing";
      group = "syncthing";
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    immich = {
      enable = true;
      openFirewall = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    samba = {
      enable = true;
      openFirewall = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    minecraft-servers = {
      enable = true;
      openFirewall = true;
    };
  };

  networking.hostName = "ant";

  networking.firewall = {
    enable = true;
    allowPing = true;
    # Open ports in the firewall.
    allowedTCPPorts = [3001];
    # allowedUDPPorts = [ ... ];
  };

  system.stateVersion = "24.11";
}
