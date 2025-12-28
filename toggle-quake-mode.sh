#!/bin/bash
# Toggle quake terminal between quake mode (pinned) and regular window mode
# Super+Shift+A: Toggle mode

QUAKE_WIDTH=500
QUAKE_HEIGHT=500
QUAKE_X=6
QUAKE_Y=44

# Check if foot-quake exists
if ! hyprctl clients -j | jq -e '.[] | select(.class == "foot-quake")' > /dev/null 2>&1; then
    notify-send "Quake Terminal" "No quake terminal is running"
    exit 1
fi

# Get current pinned state
IS_PINNED=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .pinned')

if [[ "$IS_PINNED" == "true" ]]; then
    # Currently in quake mode - convert to regular tiled window
    # Unpin, remove noborder, and tile it
    hyprctl dispatch pin class:foot-quake
    hyprctl setprop class:foot-quake noborder 0
    hyprctl dispatch togglefloating class:foot-quake
    notify-send "Quake Terminal" "Switched to tiled window" -t 1500
else
    # Currently in regular mode - convert back to quake mode
    # Float it, pin, noborder, restore position
    IS_FLOATING=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .floating')
    if [[ "$IS_FLOATING" == "false" ]]; then
        hyprctl dispatch togglefloating class:foot-quake
    fi
    hyprctl dispatch pin class:foot-quake
    hyprctl setprop class:foot-quake noborder 1
    hyprctl dispatch resizewindowpixel "exact $QUAKE_WIDTH $QUAKE_HEIGHT,class:foot-quake"
    hyprctl dispatch movewindowpixel "exact $QUAKE_X $QUAKE_Y,class:foot-quake"
    notify-send "Quake Terminal" "Switched to quake mode" -t 1500
fi
