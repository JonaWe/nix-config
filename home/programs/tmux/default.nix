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
    escapeTime = 0;
    keyMode = "vi";
    prefix = "C-s";
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.session-wizard;
        extraConfig = ''
          set -g @session-wizard 'T K' # for multiple key bindings
        '';
      }
    ];
  };
}
