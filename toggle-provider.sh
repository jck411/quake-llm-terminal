#!/bin/bash
# toggle-provider.sh - Toggle default provider for quake terminal
# Bound to Super+Z - cycles through: openrouter → gemini → terminal

CONFIG_DIR="$HOME/.config/quake-llm-terminal"
CONFIG_FILE="$CONFIG_DIR/default-provider"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Read current provider (default to terminal if none)
if [[ -f "$CONFIG_FILE" ]]; then
    CURRENT=$(cat "$CONFIG_FILE")
else
    CURRENT="terminal"
fi

# Cycle to next provider
case "$CURRENT" in
    openrouter)
        NEXT="gemini"
        DISPLAY_NAME="Gemini"
        ;;
    gemini)
        NEXT="groq"
        DISPLAY_NAME="Groq"
        ;;
    groq)
        NEXT="terminal"
        DISPLAY_NAME="Terminal"
        ;;
    terminal|*)
        NEXT="openrouter"
        DISPLAY_NAME="OpenRouter"
        ;;
esac

# Save new default
echo "$NEXT" > "$CONFIG_FILE"

# Show notification
notify-send -t 2000 -i terminal "Quake Terminal" "Switched to: $DISPLAY_NAME"

# Kill existing quake terminal and respawn with new provider
hyprctl dispatch closewindow class:foot-quake 2>/dev/null || true
sleep 0.3
"$(dirname "${BASH_SOURCE[0]}")/toggle-quake.sh"
