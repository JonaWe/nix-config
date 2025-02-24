{
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/ssh.nix
    ../../modules/docker.nix
    ../../modules/fonts.nix
    # ../../modules/minecraft-servers.nix
    ../../modules/steam.nix
    ../../modules/sway.nix
    ../../modules/sops.nix
  ];
  networking.hostName = "octopus";

  myconf.services = {
    syncthing = {
      enable = true;
      dataDir = "/home/jona";
      user = "jona";
      group = "users";
    };
  };

  # use grub as the bootloader for better dual booting experience
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    configurationLimit = 10;
  };

  # this sets the system time to local time to work with windows dual boot
  time.hardwareClockInLocalTime = true;

  boot.supportedFilesystems = ["ntfs"];

  boot.blacklistedKernelModules = ["nouveau"];
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  hardware.graphics = {
    enable = true;
  };

  networking.hosts = {
    "192.168.188.133" = ["home.lab"];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [3001];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
