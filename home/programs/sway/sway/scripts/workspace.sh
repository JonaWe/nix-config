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
    swaymsg "[workspace=${WORKSPACE}] move workspace to output current"
    exit 0
fi

# otherwise create the workspace on the current monitor
swaymsg workspace $WORKSPACE
