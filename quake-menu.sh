#!/bin/bash
# quake-menu.sh - Startup menu for quake terminal
# Shows quick selection for backend mode on fresh session

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="/home/human/REPOS/Backend_FastAPI"
SHELL_CHAT="$BACKEND_DIR/.venv/bin/shell-chat"
GEMINI_CHAT="/home/human/REPOS/gemini-cli/.venv/bin/gemini-chat"
GROQ_CHAT="/home/human/REPOS/groq-cli/.venv/bin/groq-chat"

# Session cache directories
SHELL_CHAT_SESSION="$HOME/.cache/shell-chat/session_id"
GEMINI_SESSION="$HOME/.cache/gemini-cli/session_id"

# Clear session caches for fresh start
clear_sessions() {
    rm -f "$SHELL_CHAT_SESSION" 2>/dev/null
    rm -f "$GEMINI_SESSION" 2>/dev/null
}

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

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
    echo -n "Waiting for backend..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo -e " ${GREEN}ready!${NC}"
            return 0
        fi
        sleep 0.5
        attempt=$((attempt + 1))
        echo -n "."
    done
    echo -e " ${YELLOW}timeout${NC}"
    return 1
}

# Start MCP servers only (detached so they survive terminal close)
start_mcp() {
    echo -e "${YELLOW}Starting MCP servers...${NC}"
    cd "$BACKEND_DIR"
    nohup ./start.sh 2 > /dev/null 2>&1 &
    disown
    sleep 3
    cd "$SCRIPT_DIR"
}

# Start backend + MCP (detached so they survive terminal close)
start_backend_and_mcp() {
    echo -e "${YELLOW}Starting Backend + MCP servers...${NC}"
    cd "$BACKEND_DIR"
    nohup ./start.sh 12 > /dev/null 2>&1 &
    disown
    cd "$SCRIPT_DIR"
    wait_for_backend
}

# Display menu
clear_sessions  # Fresh menu = fresh session
clear
echo ""
echo -e "${BOLD}╔═══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         Quake Terminal - Select       ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}1${NC}) OpenRouter  ${GREEN}(shell-chat via Backend)${NC}"
echo -e "  ${CYAN}2${NC}) Gemini      ${GREEN}(gemini-chat direct)${NC}"
echo -e "  ${CYAN}3${NC}) Groq        ${GREEN}(groq-chat direct)${NC}"
echo -e "  ${CYAN}4${NC}) Terminal    ${GREEN}(plain shell)${NC}"
echo ""
echo -n -e "${BOLD}Select [1-4]:${NC} "
read -r choice

case "$choice" in
    1)
        clear
        # Start backend + MCP if not running
        if ! is_backend_running; then
            start_backend_and_mcp
        elif ! is_mcp_running; then
            start_mcp
        fi
        
        if [[ -x "$SHELL_CHAT" ]]; then
            exec "$SHELL_CHAT"
        else
            echo "shell-chat not found at: $SHELL_CHAT"
            exec bash
        fi
        ;;
    2)
        clear
        # Start MCP if not running
        if ! is_mcp_running; then
            start_mcp
        fi
        
        if [[ -x "$GEMINI_CHAT" ]]; then
            exec "$GEMINI_CHAT"
        else
            echo "gemini-chat not found at: $GEMINI_CHAT"
            exec bash
        fi
        ;;
    3)
        clear
        # Start MCP if not running
        if ! is_mcp_running; then
            start_mcp
        fi
        
        if [[ -x "$GROQ_CHAT" ]]; then
            exec "$GROQ_CHAT"
        else
            echo "groq-chat not found at: $GROQ_CHAT"
            exec bash
        fi
        ;;
    4|"")
        clear
        exec bash
        ;;
    *)
        echo "Invalid choice, starting terminal..."
        sleep 1
        clear
        exec bash
        ;;
esac
