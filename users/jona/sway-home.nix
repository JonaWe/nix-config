{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home/programs/neovim
    ../../home/programs/tmux
    ../../home/programs/sway
    ../../home/programs/kitty
    ../../home/programs/zathura
    ../../home/programs/browser
    ../../home/programs/discord
    ./base-home.nix
  ];

}
