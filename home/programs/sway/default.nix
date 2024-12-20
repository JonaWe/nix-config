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
  programs.waybar.enable = true;
  # programs.sway = {
  #   enable = true;
  # };
}
