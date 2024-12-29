{
  config,
  pkgs,
  lib,
  ...
}:let
  mod = "Mod4";

  left = "h";
  down = "j";
  up = "k";
  right = "l";

  terminal = "${pkgs.kitty}/bin/kitty";
  bar = "${pkgs.waybar}/bin/waybar";

in {
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

  # services.gnome.gnome-keyring.enable = true;
  # services.dbus.enable = true;

  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images

  xdg.portal = {
      enable = true;
      config = {
          common = {
              default = [
                  "gtk"
              ];
          };
      };
# wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  wayland.windowManager.sway = {
      enable = true;
      # workaround for gcj keyboard layout
      checkConfig = false;

      config = rec {
          modifier = "Mod4";
          terminal = "kitty";
          bars = [
            { command = bar; }
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
          output = {
              DP-1 = {
                  mode = "2560x1440@144Hz";
              };
          };
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
          window = {
              border = 1;
              titlebar = false;
              hideEdgeBorders = "none";
          };
          floating = {
            border = 1;
            titlebar = false;
          };
          startup = [
            { command = "dbus-sway-environment"; always = true; }
            { command = "systemctl --user import-environment"; always = true; }
          ];
          keybindings = {
          # keybindings = lib.mkOptionDefault {
            "${mod}+q" = "kill";
            "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";
            "${mod}+d" = "exec ${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons";
            "${mod}+Shift+d" = "exec ${pkgs.rofi-wayland}/bin/rofi -show calc -modi calc -no-show-match -no-sort";
            "${mod}+e" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
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

            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
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

      extraOptions = [ "--unsupported-gpu" ];
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

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  # programs.sway = {
  #   enable = true;
  #
  #
  # };
  # services.greetd = {
  #   enable = true;
  #   systemdIntegration = {
  #     enable = true;
  #     extraVariables = ["DISPLAY" "HYPRLAND_INSTANCE_SIGNATURE"];
  #   };
  #   settings = rec {
  #     initial_session = {
  #       command = "${pkgs.sway}/bin/sway --unsupported-gpu";
  #       # command = "${pkgs.sway}/bin/sway --unsupported-gpu";
  #       user = "jona";
  #     };
  #     default_session = initial_session;
  #   };
  # };

  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;
}
