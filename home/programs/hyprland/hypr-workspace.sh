#!/usr/bin/env bash

# name of the workspace that should be moved
WORKSPACE="$1"

# get the workspace of the workspace that should be moved
WORKSPACE_MONITOR=$(hyprctl workspaces -j | jq --arg ws "$WORKSPACE" '.[] | select(.name == $ws) | .monitorID')

# check if the workspace even exists, otherwise create it
if [ -z "$WORKSPACE_MONITOR" ]; then
    hyprctl dispatch workspace $WORKSPACE
    exit 0
fi

# get the id of the currently focused output monitor
CURRENT_OUTPUT=$(hyprctl monitors -j | jq '.[] | select(.focused) | .id')

# if the workspace is on the active monitor just switch to it
if [ "$CURRENT_OUTPUT" = "$WORKSPACE_MONITOR" ]; then
    hyprctl dispatch workspace $WORKSPACE
    exit 0
fi

# get the active workspace from the target monitor (e.g. the monitor that has the target workspace on it)
ACTIVE_WORKSPACE_TARGET_MONITOR=$(hyprctl monitors -j | jq ".[] | select(.id == $WORKSPACE_MONITOR) | .activeWorkspace | .id")

# check if the target workspace is already displayed on another monitor.
# if so, then just switch focus to the other monitor
if [ "$ACTIVE_WORKSPACE_TARGET_MONITOR" = "$WORKSPACE" ]; then
    hyprctl dispatch workspace $WORKSPACE
    exit 0
fi

# otherwise, the workspace is inactive on a monitor that is not focused
# -> move the workspace to the current monitor and focus it
ACTIVE_MONITOR=$(hyprctl monitors -j | jq '.[] | select(.focused) | .id')
hyprctl dispatch moveworkspacetomonitor $WORKSPACE $ACTIVE_MONITOR
hyprctl dispatch workspace $WORKSPACE
