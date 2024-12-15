{pkgs, ...}: {
  home.file.".config/zathura/zathurarc".source = ./zathurarc;
  home.packages = with pkgs; [
    zathura
  ];
}
