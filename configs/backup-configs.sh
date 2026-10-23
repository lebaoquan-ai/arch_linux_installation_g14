#!/usr/bin/env bash
# ==============================================================================
# backup-configs.sh
# Syncs active configuration files from home directory into this setup repo.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Backing up system & application configurations..."

mkdir -p "${SCRIPT_DIR}/"{nvim,fish,cbar,fcitx5,mise,rog,cosmic,applications,bash}

# Neovim
[ -d "${HOME}/.config/nvim" ] && cp -r "${HOME}/.config/nvim/"* "${SCRIPT_DIR}/nvim/"

# Fish
[ -d "${HOME}/.config/fish" ] && cp -r "${HOME}/.config/fish/"* "${SCRIPT_DIR}/fish/"

# Cbar & custom panel plugins
[ -d "${HOME}/.config/cbar" ] && cp -r "${HOME}/.config/cbar/"* "${SCRIPT_DIR}/cbar/"

# Fcitx5 Vietnamese input
[ -d "${HOME}/.config/fcitx5" ] && cp -r "${HOME}/.config/fcitx5/"* "${SCRIPT_DIR}/fcitx5/"

# Mise tool definitions
[ -d "${HOME}/.config/mise" ] && cp -r "${HOME}/.config/mise/"* "${SCRIPT_DIR}/mise/"

# ASUS ROG settings
[ -d "${HOME}/.config/rog" ] && cp -r "${HOME}/.config/rog/"* "${SCRIPT_DIR}/rog/"

# COSMIC Desktop settings
[ -d "${HOME}/.config/cosmic" ] && cp -r "${HOME}/.config/cosmic/"* "${SCRIPT_DIR}/cosmic/"

# Desktop app entries & PWAs
mkdir -p "${SCRIPT_DIR}/applications"
find "${HOME}/.local/share/applications" -maxdepth 1 -name "*.desktop" -exec cp {} "${SCRIPT_DIR}/applications/" \; 2>/dev/null || true

# Bash configuration
[ -f "${HOME}/.bashrc" ] && cp "${HOME}/.bashrc" "${SCRIPT_DIR}/bash/.bashrc"
[ -f "${HOME}/.bash_profile" ] && cp "${HOME}/.bash_profile" "${SCRIPT_DIR}/bash/.bash_profile"

echo -e "${GREEN}✓ All active configurations backed up to ${SCRIPT_DIR}!${NC}"
