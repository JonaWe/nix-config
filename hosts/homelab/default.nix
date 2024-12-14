{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/base.nix
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["zfs" "ntfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "37dff6a3";
  # create the pool
  # zpool create -f -o ashift=12 -o compression=lz4 unraidedpool deviceid
  # zfs create -o mount=legacy unraided/media
  fileSystems."/mnt/media" = {
    device = "unraidedpool/media";
    fsType = "zfs";
  };

  networking.hostName = "homelab";

  environment.systemPackages = with pkgs; [
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     tmux
     btop
     kitty
     git
     wget

     jellyfin
     jellyfin-web
     jellyfin-ffmpeg
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
  services.fail2ban.enable = true;

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "jona" ];
nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      # vpl-gpu-rt # QSV on 11th gen or newer
      intel-media-sdk # QSV up to 11th gen
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.samba = {
    openFirewall = true;
    enable = true;
    settings = {
      global = {
        "server string" = "Nix Samba Share";
        "netbios name" = "smbnix";
        security = "user";
        "hosts allow" = "192.168.188. 127.0.0.1 localhost";
        "host deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        path = "/mnt/media";
        "read only" = "no";
        browsable = "yes";
        "guest ok" = "yes";
        comment = "public samba share";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # services.immich = {
  #   enable = true;
  #   environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
  # };

  # users.users.immich.extraGroups = [ "video" "render" ];


  networking.firewall = {
    enable = true;
    allowPing = true;
    # Open ports in the firewall.
    allowedTCPPorts = [ 3001 ];
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
