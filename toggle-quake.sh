#!/bin/bash
# Toggle quake terminal - show/hide dropdown terminal
# This is a simple dumb terminal. Use quake-switch inside to change modes.

FOOT_CONFIG="$HOME/.config/foot-quake/foot-quake.ini"
QUAKE_VISIBLE_Y=44
QUAKE_HIDDEN_Y=-600

# Check if foot-quake is running
if ! hyprctl clients -j | jq -e '.[] | select(.class == "foot-quake")' > /dev/null 2>&1; then
    # Not running - spawn a plain terminal
    foot --config "$FOOT_CONFIG" &
    exit 0
fi

# Get current Y position of quake terminal
CURRENT_Y=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .at[1]')

if [[ "$CURRENT_Y" -ge 0 ]]; then
    # Currently visible - hide it by moving offscreen (above the screen)
    hyprctl dispatch movewindowpixel "exact 6 $QUAKE_HIDDEN_Y,class:foot-quake"
else
    # Currently hidden - show it by moving back to visible position
    hyprctl dispatch movewindowpixel "exact 6 $QUAKE_VISIBLE_Y,class:foot-quake"
    hyprctl dispatch focuswindow class:foot-quake
fi
