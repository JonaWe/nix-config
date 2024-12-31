{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    neovim
    alejandra
    nixd
  ];
}
