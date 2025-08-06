{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./base-home.nix
    ../../home/programs/sway
    ../../home/programs/kitty
    ../../home/programs/zathura
    ../../home/programs/browser
    ../../home/programs/discord
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
      pkgs.kdePackages.xdg-desktop-portal-kde
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
    # jetbrains.idea-ultimate
    jetbrains-toolbox
    keepassxc
    gparted
    polkit_gnome
    networkmanagerapplet
    # swaynotificationcenter
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
    gnome-contacts
    # gnome-control-center
    # gnome-desktop
    # kdePackages.merkuro
    jellyfin-media-player
    imv
    mongodb-compass
  ];

}
