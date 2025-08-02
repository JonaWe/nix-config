{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./swaync.nix
    ./mimeapps.nix
    ./themes.nix
    ./sway.nix
    ./kanshi.nix
    ./swayidle.nix
  ];

  home.file.".config/xkb" = {
    source = ./xkb;
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = ./waybar;
    recursive = true;
  };
  home.file.".config/rofi" = {
    source = ./rofi;
    recursive = true;
  };
  home.file.".config/swaylock" = {
    source = ./swaylock;
    recursive = true;
  };

  programs.waybar.enable = true;

  home.packages = with pkgs; [
    rofi-wayland
    pcmanfm
    kitty
    wlsunset
    blueman
    cliphist
    vlc
    swww
    libreoffice
    nautilus
    anki
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US-large
    kdePackages.okular
    makemkv
    mullvad-vpn
    qbittorrent
    xournalpp
    wdisplays
    libnotify
    wl-color-picker
    wireshark
    # davinci-resolve
  ];

  nixpkgs.config.allowUnfree = true;

  services.blueman-applet.enable = true;

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "\$HOME/documents";
      download = "\$HOME/downloads";
      pictures = "\$HOME/pictures";
      videos = "\$HOME/videos";
    };
  };
}
