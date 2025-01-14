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
    shortcut = "s";
    extraConfig = ''
      bind q kill-pane

      # move between panes
      bind h select-pane -L
      bind l select-pane -R
      bind k select-pane -U
      bind j select-pane -D

      # create new panes
      bind s split-window -v
      bind S split-window -v -b
      bind v  split-window -h
      bind V split-window -h -b

    '';
  };
}
