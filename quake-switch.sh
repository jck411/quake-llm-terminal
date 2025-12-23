#!/bin/bash
# quake-switch - Start chat mode from terminal
# Usage: quake-switch <openrouter|gemini>

SHELL_CHAT="/home/human/REPOS/Backend_FastAPI/.venv/bin/shell-chat"
GEMINI_CHAT="/home/human/REPOS/gemini-cli/.venv/bin/gemini-chat"

show_help() {
    echo "Usage: quake-switch <openrouter|gemini>"
    echo ""
    echo "  openrouter  - shell-chat (OpenRouter via Backend)"
    echo "  gemini      - gemini-chat (Gemini API direct)"
    echo ""
    echo "Use /quit to return to shell"
}

case "$1" in
    openrouter)
        clear
        if ! pgrep -f "uvicorn.*backend" > /dev/null 2>&1; then
            echo "Backend not running. Start it first with waybar widget or:"
            echo "  cd /home/human/REPOS/Backend_FastAPI && ./start-backend.sh"
            exit 1
        fi
        
        if [[ -x "$SHELL_CHAT" ]]; then
            exec "$SHELL_CHAT"
        else
            echo "shell-chat not found at: $SHELL_CHAT"
            exit 1
        fi
        ;;
    gemini)
        clear
        if [[ -x "$GEMINI_CHAT" ]]; then
            exec "$GEMINI_CHAT"
        else
            echo "gemini-chat not found at: $GEMINI_CHAT"
            exit 1
        fi
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "Unknown: $1"
        show_help
        exit 1
        ;;
esac
