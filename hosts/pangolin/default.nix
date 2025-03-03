{
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
    ../../modules/sway.nix
    ../../modules/steam.nix
    ../../modules/bluetooth.nix
    ../../modules/powermanagement.nix
    ../../modules/sops.nix
    ../../modules/wireguard-client.nix
  ];

  boot.supportedFilesystems = ["ntfs"];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = ["amdgpu"];

  myconf.disk = {
    enable = true;
    rootPool = {
      enable = true;
      encrypted = true;
      # drive = "/dev/disk/by-id/nvme-eui.ace42e0035e9a7b32ee4ac0000000001";
      drive = "/dev/disk/by-id/nvme-SKHynix_HFS002TEJ9X162N_ASCAN41151140A92T";
    };
  };

  myconf.services = {
    arr = {
      enable = true;
    };
    syncthing = {
      enable = true;
      dataDir = "/home/jona";
      user = "jona";
      group = "users";
    };
  };

  services.mullvad-vpn.enable = true;
  services.gnome = {
    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
  };

  networking.hosts = {
    "192.168.188.133" = ["home.lab"];
  };

  networking.hostName = "pangolin";

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems."/mnt/share" = {
    device = "//192.168.188.133/winkelsheim";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      # TODO: replace uid and gid with variables
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,uid=1000,gid=100";
      # in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    in ["${automount_opts}"];
  };

  system.stateVersion = "24.11";
}
