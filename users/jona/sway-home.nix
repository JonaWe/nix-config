{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home/programs/neovim
    ../../home/programs/tmux
    ../../home/programs/sway
    ./base-home
  ];

}
