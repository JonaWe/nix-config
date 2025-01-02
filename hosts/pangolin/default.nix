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
    # ../../modules/jellyfin.nix
    ../../modules/fonts.nix
    ../../modules/sway.nix
    ../../modules/steam.nix
    ../../modules/bluetooth.nix
    ../../modules/powermanagement.nix
  ];
  networking.hostName = "pangolin";
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-2bf3e013-c763-4185-887a-044c1fbc2eaa".device = "/dev/disk/by-uuid/2bf3e013-c763-4185-887a-044c1fbc2eaa";

  services.xserver.videoDrivers = ["amdgpu"];

  system.stateVersion = "24.11";
}
