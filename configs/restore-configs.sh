#!/usr/bin/env bash
# ==============================================================================
# restore-configs.sh
# Deploys configuration files from this setup repo into the target user profile.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Deploying configurations to user home directory..."

# Neovim
mkdir -p "${HOME}/.config/nvim"
cp -r "${SCRIPT_DIR}/nvim/"* "${HOME}/.config/nvim/"

# Fish
mkdir -p "${HOME}/.config/fish"
cp -r "${SCRIPT_DIR}/fish/"* "${HOME}/.config/fish/"

# Cbar & panel plugins
mkdir -p "${HOME}/.config/cbar"
cp -r "${SCRIPT_DIR}/cbar/"* "${HOME}/.config/cbar/"
find "${HOME}/.config/cbar/plugins" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
[ -f "${HOME}/.config/cbar/todo_action.sh" ] && chmod +x "${HOME}/.config/cbar/todo_action.sh"

# Fcitx5
mkdir -p "${HOME}/.config/fcitx5"
cp -r "${SCRIPT_DIR}/fcitx5/"* "${HOME}/.config/fcitx5/"

# Mise
mkdir -p "${HOME}/.config/mise"
cp -r "${SCRIPT_DIR}/mise/"* "${HOME}/.config/mise/"

# ASUS ROG settings (if relevant)
if [ -d "${SCRIPT_DIR}/rog" ]; then
    mkdir -p "${HOME}/.config/rog"
    cp -r "${SCRIPT_DIR}/rog/"* "${HOME}/.config/rog/"
fi

# COSMIC Desktop settings
mkdir -p "${HOME}/.config/cosmic"
cp -r "${SCRIPT_DIR}/cosmic/"* "${HOME}/.config/cosmic/"

# Desktop entries
mkdir -p "${HOME}/.local/share/applications"
if [ -d "${SCRIPT_DIR}/applications" ]; then
    cp -r "${SCRIPT_DIR}/applications/"* "${HOME}/.local/share/applications/"
    update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
fi

# Bash configurations
[ -f "${SCRIPT_DIR}/bash/.bashrc" ] && cp "${SCRIPT_DIR}/bash/.bashrc" "${HOME}/.bashrc"
[ -f "${SCRIPT_DIR}/bash/.bash_profile" ] && cp "${SCRIPT_DIR}/bash/.bash_profile" "${HOME}/.bash_profile"

echo -e "${GREEN}✓ All configurations deployed successfully!${NC}"
