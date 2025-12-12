# Quake LLM Terminal

A quake-style dropdown terminal for LLM chat, designed for Hyprland on Wayland.

![Nord Theme](https://img.shields.io/badge/theme-Nord-88c0d0?style=flat-square)
![Hyprland](https://img.shields.io/badge/compositor-Hyprland-00c4cc?style=flat-square)
![Foot Terminal](https://img.shields.io/badge/terminal-foot-4c566a?style=flat-square)

## Features

- **Quake-style dropdown** - Slides from the left edge with `Super+A`
- **Transparent** - Configurable alpha transparency (default 0.92)
- **Nord themed** - Matches the system-wide Nord color scheme
- **Non-intrusive** - Doesn't cover waybar, positioned below it
- **Unique identity** - Separate config from main foot terminal via `app-id=foot-quake`
- **Optimized** - Lightweight, GPU-efficient for Intel UHD 615

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

The terminal slides in from the left as a 450×450 square, positioned below waybar.

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
$quakeWidth = 450
$quakeHeight = 450
$quakeX = 6      # Left margin (aligns with waybar)
$quakeY = 50     # Below waybar (44px + 6px gap)
```

After changes, reload Hyprland: `hyprctl reload`

## Files

```
quake-llm-terminal/
├── config/
│   └── foot-quake.ini      # Foot terminal config (transparency, colors)
├── hypr/
│   └── quake-rules.conf    # Hyprland rules (size, position, keybind)
├── quake-llm-terminal.desktop
├── install.sh
└── README.md
```

## System Requirements

Tested on:
- Dell XPS 13 9365 (Intel i7-8500Y, UHD 615)
- EndeavourOS (Arch-based)
- Hyprland 0.52.2
- 3200×1800 @ scale 2 (effective 1600×900)

## Uninstall

```bash
rm ~/.config/foot-quake/foot-quake.ini
rm ~/.config/hypr/quake-rules.conf
rm ~/.local/share/applications/quake-llm-terminal.desktop
# Remove source line from ~/.config/hypr/hyprland.conf
```

## License

MIT
