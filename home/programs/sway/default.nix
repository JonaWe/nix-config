{pkgs, ...}: {
  # home.file.".config/sway" = {
  #   source = ./sway;
  #   recursive = true;
  #   executable = true;
  # };
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
  programs.waybar.enable = true;
  home.packages = with pkgs; [
    rofi-wayland
    pcmanfm
    mako
    kitty
    swaynotificationcenter
  ];

  gtk = {
    enable = true;
    theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
        name = "Adawaita";
        size = 24;
    };
  };
}
