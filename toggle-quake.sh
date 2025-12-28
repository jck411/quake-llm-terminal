#!/bin/bash
# Toggle quake terminal - cycle through 3 modes with Super+A:
#   1. Quake mode (pinned, floating, dropdown)
#   2. Regular window (tiled, unpinned)
#   3. Hidden (offscreen)
#
# SUPER+Q: close window (next toggle spawns fresh)
# SUPER+Z: toggle default provider

FOOT_CONFIG="$HOME/.config/foot-quake/foot-quake.ini"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKEND_DIR="/home/human/REPOS/Backend_FastAPI"
SHELL_CHAT="$BACKEND_DIR/.venv/bin/shell-chat"
GEMINI_CHAT="/home/human/REPOS/gemini-cli/.venv/bin/gemini-chat"
GROQ_CHAT="/home/human/REPOS/groq-cli/.venv/bin/groq-chat"
CONFIG_FILE="$HOME/.config/quake-llm-terminal/default-provider"

QUAKE_WIDTH=500
QUAKE_HEIGHT=500
QUAKE_X=6
QUAKE_Y=44
QUAKE_HIDDEN_Y=-600

# Read default provider (fallback to terminal)
get_default_provider() {
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        echo "terminal"
    fi
}

# Check if services are running
is_backend_running() {
    pgrep -f "uvicorn.*backend" > /dev/null 2>&1
}

is_mcp_running() {
    pgrep -f "start_mcp_servers.py" > /dev/null 2>&1
}

# Wait for backend to be ready
wait_for_backend() {
    local max_attempts=30
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            return 0
        fi
        sleep 0.5
        attempt=$((attempt + 1))
    done
    return 1
}

# Start MCP servers only (detached)
start_mcp() {
    cd "$BACKEND_DIR"
    nohup ./start.sh 2 > /dev/null 2>&1 &
    disown
    sleep 3
    cd "$SCRIPT_DIR"
}

# Start backend + MCP (detached)
start_backend_and_mcp() {
    cd "$BACKEND_DIR"
    nohup ./start.sh 12 > /dev/null 2>&1 &
    disown
    cd "$SCRIPT_DIR"
    wait_for_backend
}

# Build the command to run based on provider
build_command() {
    local provider=$(get_default_provider)
    
    case "$provider" in
        openrouter)
            # Start backend + MCP if not running
            if ! is_backend_running; then
                start_backend_and_mcp
            elif ! is_mcp_running; then
                start_mcp
            fi
            echo "$SHELL_CHAT"
            ;;
        gemini)
            # Start MCP if not running
            if ! is_mcp_running; then
                start_mcp
            fi
            echo "$GEMINI_CHAT"
            ;;
        groq)
            # Start MCP if not running
            if ! is_mcp_running; then
                start_mcp
            fi
            echo "$GROQ_CHAT"
            ;;
        terminal|*)
            echo "bash"
            ;;
    esac
}

# Check if foot-quake is running
if ! hyprctl clients -j | jq -e '.[] | select(.class == "foot-quake")' > /dev/null 2>&1; then
    # Not running - spawn terminal in quake mode with default provider
    CMD=$(build_command)
    foot --config "$FOOT_CONFIG" -e "$CMD" &
    exit 0
fi

# Get current state
CURRENT_Y=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .at[1]')
IS_PINNED=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .pinned')
IS_FLOATING=$(hyprctl clients -j | jq -r '.[] | select(.class == "foot-quake") | .floating')

# Determine current mode and cycle to next
# Mode detection:
#   - Hidden: Y < 0 (offscreen)
#   - Quake mode: pinned && floating && visible
#   - Regular window: !pinned (tiled or floating but not pinned)

if [[ "$CURRENT_Y" -lt 0 ]]; then
    # Currently hidden -> show in quake mode
    # Ensure it's in quake mode (pinned, floating, positioned)
    if [[ "$IS_FLOATING" == "false" ]]; then
        hyprctl dispatch togglefloating class:foot-quake
    fi
    if [[ "$IS_PINNED" == "false" ]]; then
        hyprctl dispatch pin class:foot-quake
    fi
    hyprctl setprop class:foot-quake noborder 1
    hyprctl dispatch resizewindowpixel "exact $QUAKE_WIDTH $QUAKE_HEIGHT,class:foot-quake"
    hyprctl dispatch movewindowpixel "exact $QUAKE_X $QUAKE_Y,class:foot-quake"
    hyprctl dispatch focuswindow class:foot-quake
elif [[ "$IS_PINNED" == "true" ]]; then
    # Currently in quake mode -> switch to regular tiled window
    hyprctl dispatch pin class:foot-quake
    hyprctl setprop class:foot-quake noborder 0
    hyprctl dispatch togglefloating class:foot-quake
    notify-send "Quake Terminal" "Regular window" -t 1000
else
    # Currently in regular window mode -> hide
    # First restore to quake mode position, then hide
    if [[ "$IS_FLOATING" == "false" ]]; then
        hyprctl dispatch togglefloating class:foot-quake
    fi
    hyprctl dispatch pin class:foot-quake
    hyprctl setprop class:foot-quake noborder 1
    hyprctl dispatch resizewindowpixel "exact $QUAKE_WIDTH $QUAKE_HEIGHT,class:foot-quake"
    hyprctl dispatch movewindowpixel "exact $QUAKE_X $QUAKE_HIDDEN_Y,class:foot-quake"
fi
