{...}: {
  services.swaync = {
    enable = true;
    settings = {
      control-center-height = 2;
      control-center-layer = "overlay";
      control-center-margin-bottom = 12;
      control-center-margin-left = 0;
      control-center-margin-right = 8;
      control-center-margin-top = 12;
      control-center-width = 650;
      cssPriority = "application";
      control-center-positionX = "right";
      control-center-positionY = "center";
      fit-to-screen = true;
      hide-on-action = false;
      hide-on-clear = false;
      image-visibility = "when-available";
      keyboard-shortcuts = true;
      layer = "layer";
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 40;
      notification-inline-replies = true;
      notification-visibility = {
      };
      notification-window-width = 400;
      positionX = "right";
      positionY = "top";
      script-fail-notify = true;
      scripts = {
      };
      timeout = 10;
      timeout-critical = 0;
      timeout-low = 5;
      transition-time = 100;
      widget-config = {
        title = {
          text = "Notification Center";
          clear-all-button = true;
          button-text = "󰆴 Clear";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          max-lines = 1;
          text = "Notification Center";
        };
        mpris = {
          image-size = 50;
          image-radius = 5;
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
          # show-per-app-icon = true;
          show-per-app-label = true;
        };
        backlight = {
          label = "󰃟";
        };
        buttons-grid = {
          actions = [
            {
              label = "󰐥";
              command = "systemctl poweroff";
            }
            {
              label = "󰜉";
              command = "systemctl reboot";
            }
            {
              label = "󰌾";
              command = "swaylock";
            }
            {
              label = "󰕾";
              command = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
              type = "toggle";
            }
            {
              label = "󰍬";
              command = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
              type = "toggle";
            }
            {
              label = "󰖩";
              command = "notify-send network yay";
            }
            {
              label = "󰂯";
              command = "blueman-manager";
            }
            {
              active = false;
              command = "swaync-client -d";
              label = "";
              type = "toggle";
            }
            {
              active = false;
              command = "notify-send 'hey'";
              label = "󰤄";
              type = "toggle";
              update_command = "notify-send 'Hi'";
            }
            {
              active = false;
              command = "swaync-client -t";
              label = "";
              type = "toggle";
            }
          ];
        };
      };
      widgets = [
        "title"
        "notifications"
        "buttons-grid"
        "mpris"
        "volume"
        "backlight"
      ];
    };
    style = ''
          * {
        font-size: 14px;
        font-family: "Noto Sans";
        transition: 100ms;
        box-shadow: unset;
      }

      .control-center .notification-row {
        background-color: unset;
      }

      .control-center .notification-row .notification-background .notification,
      .control-center .notification-row .notification-background .notification .notification-content,
      .floating-notifications .notification-row .notification-background .notification,
      .floating-notifications.background .notification-background .notification .notification-content {
        margin-bottom: unset;
      }

      .control-center .notification-row .notification-background .notification {
        margin-top: 0.150rem;
      }

      .control-center .notification-row .notification-background .notification box,
      .control-center .notification-row .notification-background .notification widget,
      .control-center .notification-row .notification-background .notification .notification-content,
      .floating-notifications .notification-row .notification-background .notification box,
      .floating-notifications .notification-row .notification-background .notification widget,
      .floating-notifications.background .notification-background .notification .notification-content {
        border: unset;
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;

      }

      .floating-notifications.background .notification-background .notification .notification-content,
      .control-center .notification-background .notification .notification-content {
      /*  border-top: 1px solid rgba(164, 162, 167, 0.15);
        border-left: 1px solid rgba(164, 162, 167, 0.15);
        border-right: 1px solid rgba(128, 127, 132, 0.15);
        border-bottom: 1px solid rgba(128, 127, 132, 0.15);*/
        background-color: #1D1D22;
        padding: 0.818rem;
        padding-right: unset;
        margin-right: unset;
      }

      .control-center .notification-row .notification-background .notification.low .notification-content label,
      .control-center .notification-row .notification-background .notification.normal .notification-content label,
      .floating-notifications.background .notification-background .notification.low .notification-content label,
      .floating-notifications.background .notification-background .notification.normal .notification-content label {
        color: #c7c5d0;
      }

      .control-center .notification-row .notification-background .notification..notification-content image,
      .control-center .notification-row .notification-background .notification.normal .notification-content image,
      .floating-notifications.background .notification-background .notification.low .notification-content image,
      .floating-notifications.background .notification-background .notification.normal .notification-content image {
        background-color: unset;
        color: #e2e0f9;
      }

      .control-center .notification-row .notification-background .notification.low .notification-content .body,
      .control-center .notification-row .notification-background .notification.normal .notification-content .body,
      .floating-notifications.background .notification-background .notification.low .notification-content .body,
      .floating-notifications.background .notification-background .notification.normal .notification-content .body {
        color: #92919a;
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content,
      .floating-notifications.background .notification-background .notification.critical .notification-content {
        background-color: #ffb4a9;
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content image,
      .floating-notifications.background .notification-background .notification.critical .notification-content image{
        background-color: unset;
        color: #ffb4a9;
      }

      .control-center .notification-row .notification-background .notification.critical .notification-content label,
      .floating-notifications.background .notification-background .notification.critical .notification-content label {
        color: #680003;
      }

      .control-center .notification-row .notification-background .notification .notification-content .summary,
      .floating-notifications.background .notification-background .notification .notification-content .summary {
        font-family: 'Gabarito', 'Lexend', sans-serif;
        font-size: 0.9909rem;
        font-weight: 500;
      }

      .control-center .notification-row .notification-background .notification .notification-content .time,
      .floating-notifications.background .notification-background .notification .notification-content .time {
        font-family: 'Geist', 'AR One Sans', 'Inter', 'Roboto', 'Noto Sans', 'Ubuntu', sans-serif;
        font-size: 0.8291rem;
        font-weight: 500;
        margin-right: 1rem;
        padding-right: unset;
      }

      .control-center .notification-row .notification-background .notification .notification-content .body,
      .floating-notifications.background .notification-background .notification .notification-content .body {
        font-family: 'Noto Sans', sans-serif;
        font-size: 0.8891rem;
        font-weight: 400;
        margin-top: 0.310rem;
        padding-right: unset;
        margin-right: unset;
      }

      .control-center .notification-row .close-button,
      .floating-notifications.background .close-button {
        background-color: unset;
        border-radius: 100%;
        border: none;
        box-shadow: none;
        margin-right: 13px;
        margin-top: 6px;
        margin-bottom: unset;
        padding-bottom: unset;
        min-height: 20px;
        min-width: 20px;
        text-shadow: none;
      }

      .control-center .notification-row .close-button:hover,
      .floating-notifications.background .close-button:hover {
        background-color: rgba(255, 255, 255, 0.15);
      }

      .control-center {
        border-radius: 1.705rem;
        -gtk-outline-radius: 1.705rem;
        border-top: 1px solid rgba(164, 162, 167, 0.19);
        border-left: 1px solid rgba(164, 162, 167, 0.19);
        border-right: 1px solid rgba(128, 127, 132, 0.145);
        border-bottom: 1px solid rgba(128, 127, 132, 0.145);
        box-shadow: 0px 2px 3px rgba(0, 0, 0, 0.45);
        margin: 7px;
        background-color: #14141B;
        padding: 1.023rem;
      }

      .control-center trough {
        background-color: #45475a;
        border-radius: 9999px;
        -gtk-outline-radius: 9999px;
        min-width: 0.545rem;
        background-color: transparent;
      }

      .control-center slider {
        border-radius: 9999px;
        -gtk-outline-radius: 9999px;
        min-width: 0.273rem;
        min-height: 2.045rem;
        background-color: rgba(199, 197, 208, 0.31);
      }

      .control-center slider:hover {
        background-color: rgba(199, 197, 208, 0.448);
      }

      .control-center slider:active {
        background-color: #77767e;
      }

      /* title widget */

      .widget-title {
        padding: 0.341rem;
        margin: unset;
      }

      .widget-title label {
        font-family: 'Gabarito', 'Lexend', sans-serif;
        font-size: 1.364rem;
        color: #e4e1e6;
        margin-left: 0.941rem;
      }

      .widget-title button {
        border: unset;
        background-color: unset;
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
        padding: 0.141rem 0.141rem;
        margin-right: 0.841rem;
      }

      .widget-title button label {
        font-family: 'Gabarito', sans-serif;
        font-size: 1.0409rem;
        color: #e4e1e6;
        margin-right: 0.841rem;
      }

      .widget-title button:hover {
        background-color: rgba(128, 128, 128, 0.3);
      }

      .widget-title button:active {
        background-color: rgba(128, 128, 128, 0.7);
      }

      /* Buttons widget */

      .widget-buttons-grid {
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
        padding: 0.341rem;
        background-color: rgba(28, 28, 34, 0.35);
        padding: unset;
      }

      .widget-buttons-grid>flowbox {
        padding: unset;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:first-child {
        margin-left:unset ;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button {
        border:none;
        background-color: unset;
        border-radius: 9999px;
        min-width: 5.522rem;
        min-height: 2.927rem;
        padding: unset;
        margin: unset;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button label {
        font-family: "Materials Symbol Rounded";
        font-size: 1.3027rem;
        color: #e4e1e6;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:hover {
        background-color: rgba(128, 128, 128, 0.3);
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:checked {
        /* OnePlus McClaren edition Orange accent */
        background-color: #ff9f34;
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:checked label {
        color: #14141B;
      }


      /* Volume widget */

      .widget-volume {
        background-color: rgba(28, 28, 34, 0.35);
        padding: 8px;
        margin: 8px;
        -gtk-outline-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
      }

      .widget-volume trough {
        /* OnePlus McClaren edition Orange accent */
        border:unset;
        background-color: rgba(128, 128, 128, 0.4);
      }


      .widget-volume trough slider {
        /* OnePlus McClaren edition Orange accent */
        color:unset;
        background-color: #ff9f34;
        border-radius: 100%;
        min-height: 1.25rem;
      }


      /* Mpris widget */

      .widget-mpris {
        background-color: rgba(28, 28, 34, 0.35);
        padding: 8px;
        margin: 8px;
        border-radius: 1.159rem;
        -gtk-outline-radius: 1.159rem;
      }

      .widget-mpris-player {
        padding: 8px;
        margin: 8px;
      }

      .widget-mpris-title {
        font-weight: bold;
        font-size: 1.25rem;
      }

      .widget-mpris-subtitle {
        font-size: 1.1rem;
      }
    '';
  };
}
