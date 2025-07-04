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
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  nixpkgs.config.cudaSupport = true;

  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:5MypNHgYuLSEraEx38+mRWje6Lg5MZ9YnhEbXZaxGbQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

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
    radicale = {
      enable = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    unifi-controller = {
      enable = true;
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
    searx = {
      enable = true;
    };
    # karakeep = {
    #   enable = true;
    # };
    actual = {
      enable = true;
    };
    wallos = {
      enable = true;
    };
    metube = {
      enable = true;
    };
    it-tools.enable = true;
    grocy = {
      enable = true;
    };
    homepage = {
      enable = true;
      # openFirewall = true;
    };
    home-assistant = {
      enable = true;
      openFirewall = true;
      zfsIntegration.enable = true;
      zfsIntegration.enableBackups = true;
    };
    tailscale = {
      enable = true;
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
    stirling-pdf = {
      enable = true;
    };
    llm = {
      enable = true;
    };
    paperless = {
      enable = true;
    };
    arr = {
      enable = true;
      dataDir.base = "/data/media/jellyfin";
      libDir.base = "/data/media/arr-services";
      qbittorrent = {
        enable = true;
        openFirewall = true;
      };
      recommendarr = {
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
