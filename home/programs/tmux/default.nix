{pkgs, ...}: {
  # home.file.".config/tmux/tmux.conf".source = ./tmux.conf;
  # home.packages = with pkgs; [
  #   tmux
  #   tmuxPlugins.session-wizard
  # ];
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
  };
}
