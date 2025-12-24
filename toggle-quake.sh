#!/bin/bash
# Toggle quake terminal - show/hide dropdown terminal
# SUPER+A: hide/show (preserves session)
# SUPER+Q: close window (next toggle spawns fresh)
# SUPER+Z: toggle default provider

FOOT_CONFIG="$HOME/.config/foot-quake/foot-quake.ini"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
BACKEND_DIR="/home/human/REPOS/Backend_FastAPI"
SHELL_CHAT="$BACKEND_DIR/.venv/bin/shell-chat"
GEMINI_CHAT="/home/human/REPOS/gemini-cli/.venv/bin/gemini-chat"
CONFIG_FILE="$HOME/.config/quake-llm-terminal/default-provider"

QUAKE_VISIBLE_Y=44
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
        terminal|*)
            echo "bash"
            ;;
    esac
}

# Check if foot-quake is running
if ! hyprctl clients -j | jq -e '.[] | select(.class == "foot-quake")' > /dev/null 2>&1; then
    # Not running - spawn terminal with default provider
    CMD=$(build_command)
    foot --config "$FOOT_CONFIG" -e "$CMD" &
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
