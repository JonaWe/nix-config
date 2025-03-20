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
    # ../../modules/ddclient.nix
    # ../../modules/gitea.nix
    # ../../modules/radicale.nix
    # ../../modules/nginx.nix
    # ../../modules/wireguard-server.nix
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
    gitea = {
      enable = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    immich = {
      enable = true;
      # openFirewall = true;
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
    adguardhome = {
      enable = true;
      openFirewall = true;
    };
    homepage = {
      enable = true;
      # openFirewall = true;
    };
    home-assistant = {
      enable = false;
      openFirewall = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      user = "arr";
      group = "arr";
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    nginx = {
      enable = true;
      openFirewall = true;
    };
    tandoor-recipes = {
      enable = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    arr = {
      enable = true;
      dataDir.base = "/data/media/jellyfin";
      libDir.base = "/data/media/arr-services";
      qbittorrent = {
        enable = true;
        openFirewall = true;
      };
      prowlarr = {
        enable = true;
        openFirewall = true;
      };
      sonarr = {
        enable = true;
        openFirewall = true;
      };
      radarr = {
        enable = true;
        openFirewall = true;
      };
      readarr = {
        enable = true;
        openFirewall = true;
      };
      lidarr = {
        enable = true;
        openFirewall = true;
      };
      jellyseerr = {
        enable = true;
        openFirewall = true;
      };
      bazarr = {
        enable = true;
        openFirewall = true;
      };
      flaresolverr = {
        enable = true;
      };
    };
  };

  networking.hostName = "ant";

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [3001 5200];
    allowedUDPPorts = [5201];
  };

  system.stateVersion = "24.11";
}
