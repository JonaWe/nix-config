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
    # ../../modules/samba.nix
    ../../modules/jellyfin.nix
    ../../modules/fonts.nix
    ../../modules/sway.nix
    ../../modules/steam.nix
    ../../modules/bluetooth.nix
    ../../modules/powermanagement.nix
  ];
  boot.supportedFilesystems = [ "ntfs" ];

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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-2bf3e013-c763-4185-887a-044c1fbc2eaa".device = "/dev/disk/by-uuid/2bf3e013-c763-4185-887a-044c1fbc2eaa";

  services.xserver.videoDrivers = ["amdgpu"];

  system.stateVersion = "24.11";
}
