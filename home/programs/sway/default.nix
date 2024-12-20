{pkgs, ...}: {
  home.file.".config/sway" = {
    source = ./sway;
    recursive = true;
    executable = true;
  };
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
  programs.rofy-wayland.enable = true;
  # programs.sway = {
  #   enable = true;
  # };
}
