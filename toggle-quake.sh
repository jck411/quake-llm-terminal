#!/bin/bash
# Toggle quake terminal - simple spawn/focus approach
# Pinned windows show on all workspaces automatically

FOOT_CONFIG="$HOME/.config/foot-quake/foot-quake.ini"
SHELL_CHAT="/home/human/REPOS/Backend_FastAPI/.venv/bin/shell-chat"

if ! pgrep -f "foot-quake" > /dev/null; then
    # Not running - spawn it
    exec foot --config "$FOOT_CONFIG" "$SHELL_CHAT"
else
    # Running - just focus it (pinned windows are always visible)
    hyprctl dispatch focuswindow class:foot-quake
fi
