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
    mouse = true;
    clipboard = true;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.session-wizard;
        extraConfig = ''
          set -g @session-wizard 'Space'
        '';
      }
    ];
    extraConfig = ''
      bind q kill-pane
      bind-key -n C-b send-prefix

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

      set -g status-position bottom
      set -g status-style bg=default,fg=white
      set -g pane-border-style fg=black
      set -g pane-active-border-style fg=yellow

      set -g clock-mode-colour yellow


      set -g status-justify centre

      set -g status-left-length 50
      set -g status-left '#[fg=cyan]#(whoami) #[fg=magenta]#{session_name}'

      set -g status-right-length 50
      set -g status-right ""
      # set -g status-right '#(date +%A\ %d.%m.%y\ %H:%M)'

      set -g status-interval 1

      set -g window-status-format '#{window_index}:#{window_name}#{window_flags}'
      set -g window-status-current-format '#[fg=yellow]#{window_index}:#{window_name}#{window_flags}'
    '';
  };
}
