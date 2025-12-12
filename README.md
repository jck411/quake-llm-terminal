# Quake LLM Terminal

A quake-style dropdown terminal for LLM chat, designed for Hyprland on Wayland.

![Nord Theme](https://img.shields.io/badge/theme-Nord-88c0d0?style=flat-square)
![Hyprland](https://img.shields.io/badge/compositor-Hyprland-00c4cc?style=flat-square)
![Foot Terminal](https://img.shields.io/badge/terminal-foot-4c566a?style=flat-square)

## Architecture

This repo provides **window configuration only**. The actual chat client (`shell-chat`) lives in [Backend_FastAPI](../Backend_FastAPI).

```
┌─────────────────────────────────────────────┐
│         Backend_FastAPI (server)            │
│  - FastAPI server (:8000)                   │
│  - shell-chat CLI (this terminal runs it)  │
│  - Svelte frontend (browser alternative)    │
└─────────────────────────────────────────────┘
                    ▲
                    │ HTTP/SSE
                    │
┌─────────────────────────────────────────────┐
│      quake-llm-terminal (this repo)         │
│  - Foot terminal styling (Nord theme)       │
│  - Hyprland window rules (quake dropdown)   │
│  - Keybind: Super+A                         │
└─────────────────────────────────────────────┘
```

## Prerequisites

1. **Backend_FastAPI** must be installed and running:
   ```bash
   cd ~/REPOS/Backend_FastAPI
   pip install -e .
   ./start_server.sh  # or: uvicorn backend.app:app
   ```

2. **Foot terminal** and **Hyprland** compositor

## Features

- **Quake-style dropdown** - Slides from the left edge with `Super+A`
- **Transparent** - Configurable alpha transparency (default 0.92)
- **Nord themed** - Matches the system-wide Nord color scheme
- **Pinned** - Visible on all workspaces
- **Lightweight** - Just window config, no runtime overhead

## Installation

```bash
cd ~/REPOS/quake-llm-terminal
chmod +x install.sh
./install.sh
```

The installer will:
1. Symlink `foot-quake.ini` to `~/.config/foot-quake/`
2. Symlink `quake-rules.conf` to `~/.config/hypr/`
3. Add source line to `hyprland.conf`
4. Install desktop entry to `~/.local/share/applications/`
5. Optionally reload Hyprland

## Usage

| Keybind | Action |
|---------|--------|
| `Super+A` | Toggle quake terminal |

The terminal slides in from the left as a 500×500 square, positioned below waybar.

### Shell Chat Commands

Once inside the terminal, you have access to these commands:

| Command | Action |
|---------|--------|
| `/help` | Show all commands |
| `/clear` | Clear session (new conversation) |
| `/model` | Show current model |
| `/model <id>` | Switch model |
| `/presets` | List available presets |
| `/preset <name>` | Apply a preset |
| `/tools` | List MCP servers and status |
| `/tools <name> on` | Enable an MCP server |
| `/tools <name> off` | Disable an MCP server |
| `/system` | Show system prompt |
| `/quit` | Exit shell-chat |
| `Ctrl+D` | Exit shell-chat |

## Configuration

### Transparency

Edit `~/.config/foot-quake/foot-quake.ini`:

```ini
[colors]
# Adjust alpha (0.0 = transparent, 1.0 = opaque)
alpha=0.92
```

### Size & Position

Edit `~/.config/hypr/quake-rules.conf`:

```bash
$quakeWidth = 500
$quakeHeight = 500
$quakeX = 6      # Left margin
$quakeY = 50     # Below waybar (44px + 6px gap)
```

After changes, reload Hyprland: `hyprctl reload`

### Remote Server

To connect to a backend on a different machine:

```bash
# Set environment variable in toggle-quake.sh or ~/.bashrc
export SHELLCHAT_SERVER=http://192.168.1.100:8000
```

## Files

```
quake-llm-terminal/
├── config/
│   └── foot-quake.ini      # Foot terminal config (transparency, colors)
├── hypr/
│   └── quake-rules.conf    # Hyprland rules (size, position, keybind)
├── toggle-quake.sh         # Spawn/focus script
├── quake-llm-terminal.desktop
├── install.sh
└── README.md
```

## Uninstall

```bash
rm ~/.config/foot-quake/foot-quake.ini
rm ~/.config/hypr/quake-rules.conf
rm ~/.local/share/applications/quake-llm-terminal.desktop
# Remove source line from ~/.config/hypr/hyprland.conf
```

## License

MIT
