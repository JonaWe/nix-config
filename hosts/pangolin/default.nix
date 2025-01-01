# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-2bf3e013-c763-4185-887a-044c1fbc2eaa".device = "/dev/disk/by-uuid/2bf3e013-c763-4185-887a-044c1fbc2eaa";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.networkmanager.enable = true;

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true;

  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images

  programs.steam.enable = true;
  programs.dconf.enable = true;
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway --unsupported-gpu";
        user = "jona";
      };
      default_session = initial_session;
    };
  };

  #  boot.supportedFilesystems = ["ntfs"];

  # Bootloader.
  #  boot.loader.systemd-boot.enable = false;
  #  boot.loader.efi.canTouchEfiVariables = true;
  #  boot.loader.grub = {
  #    enable = true;
  #    device = "nodev";
  #    efiSupport = true;
  #    useOSProber = true;
  #    configurationLimit = 10;
  #  };

  networking.hostName = "pangolin";

  services.xserver.videoDrivers = ["amdgpu"];

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
