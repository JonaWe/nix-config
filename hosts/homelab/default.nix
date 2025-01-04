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
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.supportedFilesystems = ["zfs" "ntfs"];
  # boot.zfs.forceImportRoot = false;
  networking.hostId = "37dff6a3";
  # create the pool
  # zpool create -f -o ashift=12 -o compression=lz4 unraidedpool deviceid
  # zfs create -o mount=legacy unraided/media
  # fileSystems."/mnt/media" = {
  #   device = "unraidedpool/media";
  #   fsType = "zfs";
  # };

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
