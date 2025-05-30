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
    ../../modules/sops.nix
  ];
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  myconf.disk = {
    enable = true;
    ext4 = {
      enable = true;
    };
  };

  myconf.services = {
    # nginx = {
    #   enable = true;
    #   openFirewall = true;
    # };
    headscale.enable = true;
    headscale.openFirewall = true;
  };

  networking.hostName = "albatross";

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  system.stateVersion = "24.11";
}
