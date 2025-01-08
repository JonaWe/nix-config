{
  pkgs,
  lib,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    initialPassword = "changeme";
    extraGroups = ["networkmanager" "wheel" "input" "video"];
  };
  users.users.root.initialPassword = "changeme";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nix.settings.allowed-users = ["@wheel"];
  security.sudo.execWheelOnly = true;

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = lib.mkDefault "de_DE.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "de_DE.UTF-8";
    LC_MEASUREMENT = lib.mkDefault "de_DE.UTF-8";
    LC_MONETARY = lib.mkDefault "de_DE.UTF-8";
    LC_NAME = lib.mkDefault "de_DE.UTF-8";
    LC_NUMERIC = lib.mkDefault "de_DE.UTF-8";
    LC_PAPER = lib.mkDefault "de_DE.UTF-8";
    LC_TELEPHONE = lib.mkDefault "de_DE.UTF-8";
    LC_TIME = lib.mkDefault "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = lib.mkDefault "de";
    variant = lib.mkDefault "";
  };

  # Configure console keymap
  console.keyMap = lib.mkDefault "de";

  networking.networkmanager.enable = lib.mkDefault true;
  networking.firewall.enable = lib.mkDefault true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    tmux
    wireguard-tools
  ];
}
