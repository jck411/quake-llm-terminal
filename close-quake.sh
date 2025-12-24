#!/bin/bash
# close-quake.sh - Close quake terminal and clear session
# Bound to Super+Q - kills terminal for fresh start on next open

# Session cache files
SHELL_CHAT_SESSION="$HOME/.cache/shell-chat/session_id"
GEMINI_SESSION="$HOME/.cache/gemini-cli/session_id"

# Clear session caches for fresh start
rm -f "$SHELL_CHAT_SESSION" 2>/dev/null
rm -f "$GEMINI_SESSION" 2>/dev/null

# Close the quake terminal window
hyprctl dispatch closewindow class:foot-quake
