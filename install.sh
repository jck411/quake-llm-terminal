#!/bin/bash
# Quake LLM Terminal - Installation Script
# Installs the quake-style dropdown terminal for LLM chat
#
# Installation locations:
#   ~/.config/foot-quake/          - Foot terminal config
#   ~/.config/hypr/quake-rules.conf - Hyprland window rules
#   ~/.local/share/applications/   - Desktop entry
#
# This script creates symlinks for easy updates via git pull

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
HYPR_DIR="$CONFIG_DIR/hypr"
APPLICATIONS_DIR="$HOME/.local/share/applications"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create backup with timestamp
backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup"
        print_warning "Backed up existing file to: $backup"
    elif [[ -L "$target" ]]; then
        rm "$target"
        print_status "Removed existing symlink: $target"
    fi
}

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║     Quake LLM Terminal - Installer         ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# ============================================
# Install foot-quake config
# ============================================
print_status "Installing foot-quake terminal config..."

mkdir -p "$CONFIG_DIR/foot-quake"
backup_if_exists "$CONFIG_DIR/foot-quake/foot-quake.ini"
ln -sf "$SCRIPT_DIR/config/foot-quake.ini" "$CONFIG_DIR/foot-quake/foot-quake.ini"
print_success "Linked: ~/.config/foot-quake/foot-quake.ini"

# ============================================
# Install Hyprland rules
# ============================================
print_status "Installing Hyprland quake rules..."

mkdir -p "$HYPR_DIR"
backup_if_exists "$HYPR_DIR/quake-rules.conf"
ln -sf "$SCRIPT_DIR/hypr/quake-rules.conf" "$HYPR_DIR/quake-rules.conf"
print_success "Linked: ~/.config/hypr/quake-rules.conf"

# Add source line to hyprland.conf if not already present
HYPRLAND_CONF="$HYPR_DIR/hyprland.conf"
SOURCE_LINE="source = ~/.config/hypr/quake-rules.conf"

if [[ -f "$HYPRLAND_CONF" ]]; then
    if ! grep -qF "quake-rules.conf" "$HYPRLAND_CONF"; then
        echo "" >> "$HYPRLAND_CONF"
        echo "# Quake LLM Terminal" >> "$HYPRLAND_CONF"
        echo "$SOURCE_LINE" >> "$HYPRLAND_CONF"
        print_success "Added source line to hyprland.conf"
    else
        print_status "quake-rules.conf already sourced in hyprland.conf"
    fi
else
    print_warning "hyprland.conf not found at $HYPRLAND_CONF"
    print_warning "Please manually add: $SOURCE_LINE"
fi

# ============================================
# Install desktop entry
# ============================================
print_status "Installing desktop entry..."

mkdir -p "$APPLICATIONS_DIR"
backup_if_exists "$APPLICATIONS_DIR/quake-llm-terminal.desktop"
ln -sf "$SCRIPT_DIR/quake-llm-terminal.desktop" "$APPLICATIONS_DIR/quake-llm-terminal.desktop"
print_success "Linked: ~/.local/share/applications/quake-llm-terminal.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$APPLICATIONS_DIR" 2>/dev/null || true
    print_status "Updated desktop database"
fi

# ============================================
# Reload Hyprland
# ============================================
echo ""
if command -v hyprctl &> /dev/null; then
    read -p "Reload Hyprland config now? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        hyprctl reload
        print_success "Hyprland config reloaded"
    fi
fi

# ============================================
# Done
# ============================================
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║           Installation Complete!           ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "  Keybind:     Super+A  (toggle quake terminal)"
echo "  Config:      ~/.config/foot-quake/foot-quake.ini"
echo "  Transparency: Edit 'alpha' value in foot-quake.ini"
echo ""
echo "  To uninstall, run: $SCRIPT_DIR/uninstall.sh"
echo ""
