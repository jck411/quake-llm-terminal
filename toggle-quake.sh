#!/bin/bash
# Toggle quake terminal - show/hide dropdown terminal
# SUPER+A: hide/show (preserves session)
# SUPER+Q: close window (next toggle spawns fresh with menu)

FOOT_CONFIG="$HOME/.config/foot-quake/foot-quake.ini"
MENU_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/quake-menu.sh"
QUAKE_VISIBLE_Y=44
QUAKE_HIDDEN_Y=-600

# Check if foot-quake is running
if ! hyprctl clients -j | jq -e '.[] | select(.class == "foot-quake")' > /dev/null 2>&1; then
    # Not running - spawn terminal with menu
    foot --config "$FOOT_CONFIG" -e "$MENU_SCRIPT" &
    exit 0
fi

# Get current Y position of quake terminal
CURRENT_Y=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .at[1]')

if [[ "$CURRENT_Y" -ge 0 ]]; then
    # Currently visible - hide it by moving offscreen
    hyprctl dispatch movewindowpixel "exact 6 $QUAKE_HIDDEN_Y,class:foot-quake"
else
    # Currently hidden - show it
    hyprctl dispatch movewindowpixel "exact 6 $QUAKE_VISIBLE_Y,class:foot-quake"
    hyprctl dispatch focuswindow class:foot-quake
fi

