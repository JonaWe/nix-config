{pkgs, ...}: {
  home.packages = with pkgs; [
    fzf
    zoxide
  ];
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # ============================================================
      # SECTION 1: FOUNDATION & OPTIONS
      # ============================================================
      set-option -g prefix C-s
      unbind C-b
      bind-key -n C-b send-prefix

      set -g mouse on
      set -g escape-time 0
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on
      set -g automatic-rename on
      set -g detach-on-destroy off
      set -g history-limit 10000
      set -g set-clipboard on
      set -g allow-passthrough on
      setw -g mode-keys vi


      # ============================================================
      # SECTION 2: KEYMAPS
      # ============================================================
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config successfully reloaded!"

      # Kill pane without confirmation prompt
      bind q kill-pane

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Create new panes
      bind s split-window -v -c "#{pane_current_path}"
      bind S split-window -v -b -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind V split-window -h -b -c "#{pane_current_path}"

      # Lazygit floating popup
      bind -r g popup -d '#{pane_current_path}' -E -w 90% -h 90% lazygit


      # ============================================================
      # SECTION 3: ZOXIDE + FZF SESSION WIZARD
      # ============================================================
      # Binds `Prefix + Space`. Lists open sessions (recent first) and zoxide history.
      # Excludes the current session from the list.
      # - Enter OR Ctrl-y on existing session: switches to it.
      # - Enter OR Ctrl-y on zoxide directory: creates session named after folder and switches.
      # - Type a word and press `Ctrl-c` (or Enter with no matches): creates a brand new session with that name.
      # - Press `Ctrl-w` on a directory/query to open it as a new WINDOW in the current session.
      # - Press `Ctrl-x` on a session to silently kill it and refresh the menu.
      # - Press `Ctrl-u` or `Ctrl-d` to scroll the preview window up/down.
      bind Space popup -b none -E -w 70% -h 70% "\
        c=\$(printf '\\033[38;2;158;206;106m'); \
        r=\$(printf '\\033[0m'); \
        curr=\$(tmux display-message -p '#S'); \
        while true; do \
          items=\$( (tmux list-sessions -F '#{session_activity}   #{session_name}' 2>/dev/null | sort -rn | sed 's/^[0-9]* //' | grep -vx \"  \$curr\" | sed \"s//\$c\$r/\"; zoxide query -l) | awk '!seen[\$0]++' ); \
          out=\$(echo \"\$items\" | fzf \
            --ansi \
            --scheme=history \
            --tiebreak=index \
            --layout=default \
            --border=rounded \
            --border-label=' 🔭 Zessions ' \
            --border-label-pos=center \
            --separator='─' \
            --info=right \
            --prompt='> ' \
            --pointer=' ' \
            --header=' ↵/C-y: Switch │ C-w: Window │ C-c: New │ C-x: Kill │ C-u/d: Scroll Preview ' \
            --preview='target=\$(echo {} | sed \"s/.*  //\"); if tmux has-session -t \"\$target\" 2>/dev/null; then tmux capture-pane -e -pt \"\$target\"; elif [ -d \"\$target\" ]; then if command -v lsd >/dev/null 2>&1; then lsd -a --color always --icon always \"\$target\" 2>/dev/null; else ls -a --color=always \"\$target\" 2>/dev/null; fi; fi' \
            --preview-window='right:50%:border-left' \
            --color='bg+:#292e42,fg+:#c0caf5,hl:#ff9e64,hl+:#ff9e64,prompt:#7aa2f7,pointer:#7aa2f7,info:#565f89,border:#7aa2f7,separator:#7aa2f7,label:#7aa2f7,gutter:-1,header:#565f89' \
            --print-query --expect=ctrl-c,ctrl-x,ctrl-w --bind 'ctrl-y:accept,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'); \
          if [ \$? -eq 130 ]; then exit 0; fi; \
          query=\$(echo \"\$out\" | sed -n 1p); \
          key=\$(echo \"\$out\" | sed -n 2p); \
          sel=\$(echo \"\$out\" | sed -n 3p); \
          \
          if [ \"\$key\" = \"ctrl-x\" ]; then \
            target=\$(echo \"\$sel\" | sed 's/.*  //'); \
            tmux kill-session -t \"\$target\" 2>/dev/null; \
            continue; \
          fi; \
          \
          if [ \"\$key\" = \"ctrl-w\" ]; then \
            if [ -n \"\$sel\" ]; then target=\"\$sel\"; else target=\"\$query\"; fi; \
            target=\$(echo \"\$target\" | sed 's/.*  //'); \
            if [ -n \"\$target\" ]; then \
              if tmux has-session -t \"\$target\" 2>/dev/null; then \
                tmux switch-client -t \"\$target\"; \
              elif [ -d \"\$target\" ]; then \
                name=\$(basename \"\$target\" | tr . _); \
                tmux new-window -c \"\$target\" -n \"\$name\"; \
              else \
                tmux new-window -c \"\$PWD\" -n \"\$target\"; \
              fi; \
            fi; \
            exit 0; \
          fi; \
          \
          if [ \"\$key\" = \"ctrl-c\" ]; then \
            if [ -n \"\$query\" ]; then \
              tmux new-session -d -s \"\$query\" -c \"\$PWD\"; \
              tmux switch-client -t \"\$query\"; \
            fi; \
            exit 0; \
          fi; \
          \
          if [ -n \"\$sel\" ]; then target=\"\$sel\"; else target=\"\$query\"; fi; \
          target=\$(echo \"\$target\" | sed 's/.*  //'); \
          if [ -z \"\$target\" ]; then exit 0; fi; \
          \
          if tmux has-session -t \"\$target\" 2>/dev/null; then \
            tmux switch-client -t \"\$target\"; \
          elif [ -d \"\$target\" ]; then \
            name=\$(basename \"\$target\" | tr . _); \
            if tmux has-session -t \"\$name\" 2>/dev/null; then \
              tmux switch-client -t \"\$name\"; \
            else \
              tmux new-session -d -s \"\$name\" -c \"\$target\"; \
              tmux switch-client -t \"\$name\"; \
            fi; \
          else \
            tmux new-session -d -s \"\$target\" -c \"\$PWD\"; \
            tmux switch-client -t \"\$target\"; \
          fi; \
          break; \
        done"


      # ============================================================
      # SECTION 4: UI & STATUS LINE
      # ============================================================
      set -g status-position bottom
      set -g status-style bg=default,fg=white
      set -g pane-border-style fg=black
      set -g pane-active-border-style fg=yellow
      set -g clock-mode-colour yellow

      set -g status-justify centre
      set -g status-interval 1

      set -g status-left-length 50
      set -g status-left '#[fg=cyan]#(whoami) #[fg=magenta]#{session_name}'

      set -g status-right-length 50
      set -g status-right '#(date +%A\ %d.%m.%y\ %H:%M)'

      set -g window-status-format '#{window_index}:#{window_name}#{window_flags}'
      set -g window-status-current-format '#[fg=yellow]#{window_index}:#{window_name}#{window_flags}'


    '';
  };
}
