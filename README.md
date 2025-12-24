# Quake LLM Terminal

A simple dropdown (quake-style) terminal for Hyprland that can switch between shell and chat modes.

## Quick Start

1. Press your quake hotkey to open the terminal (e.g., `SUPER+A`)
2. **On fresh session**, a menu appears:
   - `1) OpenRouter` - starts backend + MCP if needed, then `shell-chat`
   - `2) Gemini` - starts MCP if needed, then `gemini-chat`
   - `3) Terminal` - plain shell

3. Inside the terminal, use `quake-switch` to change modes:

```bash
# Start chat mode (requires backend server running)
quake-switch openrouter

# Return to plain shell
quake-switch shell
```

## Installation

```bash
./install.sh
```

This will:
- Copy configs to `~/.config/foot-quake/`
- Set up Hyprland keybinding
- Create `~/.local/bin/quake-switch` symlink

## Usage

### Toggle Terminal
The terminal is toggled with a keybind (configured in `hypr/quake.conf`).

### Switch Modes

From inside the quake terminal:

| Command | Description |
|---------|-------------|
| `quake-switch backend` | Start shell-chat (requires backend) |
| `quake-switch cli` | Same as backend |
| `quake-switch shell` | Clear and return to plain shell |

The terminal stays open when switching - it just clears and runs the new command.

## Requirements

- **Hyprland** (window manager)
- **foot** (terminal)
- **Backend_FastAPI** (for chat mode) at `/home/human/REPOS/Backend_FastAPI`

## Files

- `toggle-quake.sh` - Show/hide the quake terminal
- `quake-switch.sh` - Switch between shell/chat modes (run from inside terminal)
- `config/foot-quake.ini` - Foot terminal configuration
- `hypr/quake.conf` - Hyprland keybinding
