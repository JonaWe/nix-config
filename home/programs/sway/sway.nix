{
  pkgs,
  config,
  ...
}: let
  workspace-swapper = pkgs.writeShellScriptBin "workspace-swapper" ''
    #!/bin/bash

    # get the name of the to be moved workspace
    WORKSPACE=$1

    # get name of active monitor
    CURRENT_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')

    # check if workspace is on current monitor
    ON_CURRENT_MONITOR=$(swaymsg -t get_tree | jq --arg current_output "$CURRENT_OUTPUT" --arg ws "$WORKSPACE"  -r '.. | select(.type?=="output" and .name?==$current_output) | .nodes[] | select(.name? == $ws)')

    # check if workspace is already on current monitor
    if [ ! -z "$ON_CURRENT_MONITOR" ]; then
        swaymsg workspace $WORKSPACE
        exit 0
    fi

    # check if workspace is on visible on a different monitor
    ACTIVE_ON_OTHER_MONITOR=$(swaymsg -t get_tree | jq --arg current_output "$CURRENT_OUTPUT" --arg ws "$WORKSPACE"  -r '.. | select(.type?=="output" and .name?!=$current_output) | .nodes[] | select(.name? == $ws) | recurse(.nodes[]) | select(.visible) | .name')

    # check if the window is focused on a different monitor
    if [ ! -z "$ACTIVE_ON_OTHER_MONITOR" ]; then
        swaymsg workspace $WORKSPACE
        exit 0
    fi

    # check if the workspace exists
    WORKSPACE_EXISTS=$(swaymsg -t get_tree | jq --arg ws "$WORKSPACE" -r '.. | select(.type?=="workspace" and .name? == $ws)')
    # if the workspace exists move the workspace to the current monitor
    if [ ! -z "$WORKSPACE_EXISTS" ]; then
        swaymsg "[workspace=''${WORKSPACE}] move workspace to output current"
        exit 0
    fi

    # otherwise create the workspace on the current monitor
    swaymsg workspace $WORKSPACE
  '';
in {
  home.packages = with pkgs; [
    workspace-swapper
  ];

  wayland.windowManager.sway = let
    mod = "Mod4";

    left = "h";
    down = "j";
    up = "k";
    right = "l";

    term = "${pkgs.kitty}/bin/kitty";
    bar = "${pkgs.waybar}/bin/waybar";
  in {
    enable = true;
    # workaround for gcj keyboard layout
    checkConfig = false;

    config = rec {
      modifier = "Mod4";
      terminal = term;
      bars = [
        {command = bar;}
      ];
      fonts = {
        names = ["FiraCode Nerd Font"];
        size = 10.0;
      };
      input = {
        "type:keyboard" = {
          xkb_layout = "gcj";
          xkb_options = "caps:ctrl_modifier";
          repeat_delay = "1000";
          repeat_rate = "25";
        };
        "type:touchpad" = {
          tap = "enable";
          natural_scroll = "enable";
          pointer_accel = "0.25";
          scroll_factor = "0.5";
        };
      };
      # output = {
      #   DP-1 = {
      #     mode = "2560x1440@144Hz";
      #   };
      # };
      focus = {
        forceWrapping = false;
        followMouse = false;
      };
      gaps = {
        inner = 0;
        outer = 0;
        smartBorders = "on";
        smartGaps = true;
      };
      floating = {
        border = 1;
        titlebar = false;
      };
      workspaceAutoBackAndForth = true;
      keybindings = {
        "${mod}+q" = "kill";
        "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${mod}+d" = "exec ${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons";
        "${mod}+v" = "exec rofi -modi clipboard:/home/jona/.config/rofi/modis/clipboard-history-modi.sh -show clipboard -show-icons -theme clipboard";

        # "${mod}+Shift+d" = "exec ${pkgs.rofi-wayland}/bin/rofi -show calc -modi calc -no-show-match -no-sort";
        "${mod}+e" = "exec ${pkgs.nautilus}/bin/nautilus --new-window";
        "${mod}+g" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";

        "${mod}+${left}" = "focus left";
        "${mod}+${right}" = "focus right";
        "${mod}+${up}" = "focus up";
        "${mod}+${down}" = "focus up";
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${right}" = "move right";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${down}" = "move up";
        "${mod}+b" = "workspace back_and_forth";
        # alt tab
        "Mod1+Tab" = "workspace back_and_forth";
        "${mod}+Shift+b" = "move container to workspace back_and_forth; workspace back_and_forth";

        "${mod}+Shift+v" = "split v";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+Space" = "floating toggle";
        "${mod}+Space" = "focus mode_toggle";
        "${mod}+Shift+s" = "sticky toggle";
        "${mod}+Shift+c" = "reload";

        "${mod}+Ctrl+l" = "layout toggle split tabbed";

        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioNext" = "exec --no-startup-id playerctl next";
        "XF86AudioPrev" = "exec --no-startup-id playerctl previous";
        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set 10%+";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 10%-";

        "${mod}+1" = "exec workspace-swapper 1";
        "${mod}+2" = "exec workspace-swapper 2";
        "${mod}+3" = "exec workspace-swapper 3";
        "${mod}+4" = "exec workspace-swapper 4";
        "${mod}+5" = "exec workspace-swapper 5";
        "${mod}+6" = "exec workspace-swapper 6";
        "${mod}+7" = "exec workspace-swapper 7";
        "${mod}+8" = "exec workspace-swapper 8";
        "${mod}+9" = "exec workspace-swapper 9";
        "${mod}+0" = "exec workspace-swapper 10";
        "${mod}+m" = "exec workspace-swapper 11";
        "${mod}+slash" = "exec workspace-swapper 12";
        "${mod}+p" = "exec workspace-swapper 13";
        "${mod}+comma" = "exec workspace-swapper 14";
        "${mod}+u" = "exec workspace-swapper 15";
        "${mod}+n" = "exec workspace-swapper 16";
        "${mod}+parenleft" = "exec workspace-swapper 17";
        "${mod}+i" = "exec workspace-swapper 18";
        "${mod}+o" = "exec workspace-swapper 19";
        "${mod}+period" = "exec workspace-swapper 20";

        "${mod}+Shift+1" = "move container to workspace 1; workspace 1";
        "${mod}+Shift+2" = "move container to workspace 2; workspace 2";
        "${mod}+Shift+3" = "move container to workspace 3; workspace 3";
        "${mod}+Shift+4" = "move container to workspace 4; workspace 4";
        "${mod}+Shift+5" = "move container to workspace 5; workspace 5";
        "${mod}+Shift+6" = "move container to workspace 6; workspace 6";
        "${mod}+Shift+7" = "move container to workspace 7; workspace 7";
        "${mod}+Shift+8" = "move container to workspace 8; workspace 8";
        "${mod}+Shift+9" = "move container to workspace 9; workspace 9";
        "${mod}+Shift+0" = "move container to workspace 10; workspace 10";
        "${mod}+Shift+m" = "move container to workspace 11; workspace 11";
        "${mod}+Shift+slash" = "move container to workspace 12; workspace 12";
        "${mod}+Shift+p" = "move container to workspace 13; workspace 13";
        "${mod}+Shift+comma" = "move container to workspace 14; workspace 14";
        "${mod}+Shift+u" = "move container to workspace 15; workspace 15";
        "${mod}+Shift+n" = "move container to workspace 16; workspace 16";
        "${mod}+Shift+parenleft" = "move container to workspace 17; workspace 17";
        "${mod}+Shift+i" = "move container to workspace 18; workspace 18";
        "${mod}+Shift+o" = "move container to workspace 19; workspace 19";
        "${mod}+Shift+period" = "move container to workspace 20; workspace 20";

        "${mod}+r" = "mode resize";
        "${mod}+minus" = "mode session";
      };
      modes = {
        resize = {
          "q" = "mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
          "${down}" = "resize shrink height 50 px or 50 ppt";
          "${up}" = "resize grow height 50 px or 50 ppt";
          "${left}" = "resize shrink width 50 px or 50 ppt";
          "${right}" = "resize grow width 50 px or 50 ppt";
        };
        session = {
          "q" = "mode default";
          "Return" = "mode default";
          "Escape" = "mode default";

          "Shift+s" = "exec ${pkgs.systemd}/bin/systemctl poweroff, mode default";
          "r" = "exec ${pkgs.systemd}/bin/systemctl reboot, mode default";
          "h" = "exec ${pkgs.systemd}/bin/systemctl hibernate, mode default";
          "s" = "exec ${pkgs.systemd}/bin/systemctl suspend, mode default";
          "l" = "exec ${pkgs.swaylock}/bin/swaylock, mode default";
          "Shift+l" = "exec ${pkgs.sway}/bin/swaymsg exit, mode default";
        };
      };
      startup = [
        # fixes wayland stuff
        {
          command = "dbus-sway-environment";
          always = true;
        }
        {
          command = "systemctl --user import-environment";
          always = true;
        }
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          always = true;
        }
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = true;
        }

        # service needs restart after startup
        {
          command = "systemctl --user restart swaync";
          always = true;
        }
        {
          command = "${pkgs.wlsunset}/bin/wlsunset";
          always = true;
        }
        {
          command = "wl-paste --watch cliphist store";
          always = true;
        }

        # wallpaper
        {command = "swww-daemon";}
        {command = "swww img /home/jona/bg.jpg";}

        # other stuff
        {command = "swaymsg 'workspace 17; exec ${pkgs.thunderbird}/bin/thunderbird'";}
        {command = "${pkgs.signal-desktop}/bin/signal-desktop";}
        {command = "swaymsg 'workspace 15; exec ${pkgs.telegram-desktop}/bin/telegram-desktop'";}
        {command = "${pkgs.element-desktop}/bin/element-desktop";}
        {command = "${pkgs.spotify}/bin/spotify";}
        {command = "swaymsg 'workspace 19; exec ${pkgs.kitty}/bin/kitty tmux new-session -A -s main'";}
        {command = "${pkgs.brave}/bin/brave";}
        {command = "${pkgs.brave}/bin/brave --app=https://calendar.proton.me/u/0/";}
        {command = "${pkgs.firefox}/bin/firefox";}
        {command = "${pkgs.keepassxc}/bin/keepassxc";}
        {command = "sleep 10; syncthingtray";}
      ];
      window = {
        border = 1;
        titlebar = false;
        hideEdgeBorders = "none";
        commands = [
          {
            command = "layout tabbed";
            criteria = {
              class = "Signal";
            };
          }
          {
            command = "layout tabbed";
            criteria = {
              app_id = "firefox";
            };
          }
          {
            command = "floating enable";
            criteria = {
              title = "File Transfer*";
            };
          }
        ];
      };
      assigns = {
        "11" = [
          {instance = "spotify";}
        ];
        "12" = [
          {app_id = "firefox";}
        ];
        "13" = [
          {class = "jetbrains-idea";}
        ];
        "14" = [
          {class = "obsidian";}
          {title = "Obsidian Terminal";}
        ];
        "15" = [
          {class = "Signal";}
          {class = "Element";}
          {class = "Telegram";}
        ];
        "16" = [
          {instance = "calendar.proton.me__u_0";}
        ];
        "17" = [
          {class = "thunderbird";}
        ];
        "18" = [
          {instance = "brave-browser";}
        ];
        "20" = [
          {app_id = "org.keepassxc.KeePassXC";}
        ];
      };
      seat."*" = {
        xcursor_theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
      };
      colors = let
        primary = "#F5D48f";
        secondary = "#BAF59A";
        background = "#1A1919";
      in {
        background = background;
        focused = {
          border = primary;
          background = primary;
          text = background;
          indicator = secondary;
          childBorder = primary;
        };
        focusedInactive = {
          border = background;
          background = background;
          text = secondary;
          indicator = background;
          childBorder = background;
        };
        unfocused = {
          border = background;
          background = background;
          text = primary;
          indicator = background;
          childBorder = background;
        };
        urgent = {
          border = background;
          background = background;
          text = primary;
          indicator = background;
          childBorder = background;
        };
        placeholder = {
          border = background;
          background = background;
          text = primary;
          indicator = background;
          childBorder = background;
        };
      };
    };

    extraOptions = ["--unsupported-gpu"];
    swaynag.enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    wrapperFeatures.gtk = true;
  };
}
