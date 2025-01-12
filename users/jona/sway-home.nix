{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home/programs/neovim
    ../../home/programs/tmux
    ../../home/programs/sway
    ../../home/programs/kitty
    ../../home/programs/zathura
    ../../home/programs/browser
    ../../home/programs/discord
    ./base-home.nix
  ];

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-kde
    ];
  };
  home.packages = with pkgs; [
    signal-desktop
    element-desktop
    telegram-desktop
    thunderbird
    spotify
    obsidian
    firefox
    syncthingtray
    jetbrains.idea-ultimate
    keepassxc
    gparted
    polkit_gnome
    networkmanagerapplet
    swaynotificationcenter
    libnotify
    swaylock
    wl-clipboard
    pavucontrol
    prismlauncher
    ncdu
    mangohud
    texlive.combined.scheme-full
    teamspeak3
    zoom-us
    gnome-calendar
    jellyfin-web
  ];

  services.syncthing = {
    enable = true;
    # tray.enable = true;
  };
}
