{pkgs, ...}: {
  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
  home.file.".ideavimrc" = {
    source = ./.ideavimrc;
  };

  home.packages = with pkgs; [
    neovim
    alejandra
    nixd
    go
    nodejs
    python3
    cargo
    gcc
    gnumake
    texlab
    ltex-ls
  ];
}
