#!/bin/sh
#!/run/current-system/sw/bin/bash

SERVICE="kanata-internalKeyboard.service"

# if /etc/profiles/per-user/jona/bin/systemctl/systemctl is-active --quiet "$SERVICE"; then
if systemctl is-active --quiet "$SERVICE"; then
    ICON='󰥻 '
    TOOLTIP='Kanata keyboard mapper is currently active'
else
    ICON='󰌐 '
    TOOLTIP='Kanata keyboard mapper is currently inactive'
fi

echo "{\"text\": \"$ICON\", \"tooltip\": \"$TOOLTIP\"}"
