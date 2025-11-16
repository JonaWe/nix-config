#!/run/current-system/sw/bin/bash

SERVICE="kanata-internalKeyboard.service"
TIMEOUT=2

if systemctl is-active --quiet "$SERVICE"; then
    systemctl stop "$SERVICE"
    notify-send "Kanata Keyboard" "Disabled Kanata service." --urgency=low --expire-time $(($TIMEOUT * 1000))
else
    systemctl start "$SERVICE"
    notify-send "Kanata Keyboard" "Enabled Kanata service." --urgency=low --expire-time $(($TIMEOUT * 1000))
fi

(sleep $TIMEOUT; swaync-client --close-latest) &
