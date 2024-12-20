{pkgs, ...}: {
  home.file.".config/sway" = {
    source = ./sway;
    recursive = true;
    executable = true;
  };
  # programs.sway = {
  #   enable = true;
  # };
}
