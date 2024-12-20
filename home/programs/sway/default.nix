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
  # programs.sway = {
  #   enable = true;
  # };
}
