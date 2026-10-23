#!/usr/bin/env bash
# ==============================================================================
# 3-setup-mise-and-dev.sh
# Configures polyglot developer runtimes (Node.js LTS, Python 3.11, gh CLI)
# via mise and CLI agents via pipx.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Setting up mise & developer runtimes..."

# Ensure mise is installed
if ! command -v mise &>/dev/null; then
    echo -e "${YELLOW}Installing mise via pacman...${NC}"
    sudo pacman -S --needed --noconfirm mise
fi

# Ensure config directory exists and copy mise config
mkdir -p "${HOME}/.config/mise"
if [ -f "${REPO_ROOT}/configs/mise/config.toml" ]; then
    cp "${REPO_ROOT}/configs/mise/config.toml" "${HOME}/.config/mise/config.toml"
fi

# Ensure shell activation hooks are in place
if [ -f "${HOME}/.bashrc" ] && ! grep -q "mise activate bash" "${HOME}/.bashrc"; then
    echo 'eval "$(mise activate bash)"' >> "${HOME}/.bashrc"
fi

FISH_CONF="${HOME}/.config/fish/config.fish"
if [ -f "${FISH_CONF}" ] && ! grep -q "mise activate fish" "${FISH_CONF}"; then
    echo 'mise activate fish | source' >> "${FISH_CONF}"
fi

# Install mise tools defined in ~/.config/mise/config.toml
echo -e "${YELLOW}Installing mise runtimes (Node.js LTS, Python 3.11, gh CLI)...${NC}"
mise install --yes

# Symlink gh into ~/.local/bin for global PATH access
mkdir -p "${HOME}/.local/bin"
if [ -f "${HOME}/.local/share/mise/shims/gh" ]; then
    ln -sf "${HOME}/.local/share/mise/shims/gh" "${HOME}/.local/bin/gh"
fi

# Install Hermes Agent via pipx
if command -v pipx &>/dev/null; then
    echo -e "${YELLOW}Ensuring hermes-agent is installed via pipx...${NC}"
    pipx ensurepath
    pipx install hermes-agent 2>/dev/null || pipx upgrade hermes-agent 2>/dev/null || true
fi

echo -e "${GREEN}✓ Developer runtimes & tools installed!${NC}"
