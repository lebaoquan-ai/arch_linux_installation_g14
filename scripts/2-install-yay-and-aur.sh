#!/usr/bin/env bash
# ==============================================================================
# 2-install-yay-and-aur.sh
# Installs yay (AUR helper) if missing, then installs required AUR packages.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
AURLIST="${REPO_ROOT}/pkglist/aur-apps.txt"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Setting up yay & AUR packages..."

if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}yay not found. Installing yay from AUR...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    BUILD_DIR=$(mktemp -d)
    trap 'rm -rf "${BUILD_DIR}"' EXIT
    git clone https://aur.archlinux.org/yay-bin.git "${BUILD_DIR}/yay-bin"
    (cd "${BUILD_DIR}/yay-bin" && makepkg -si --noconfirm)
fi

echo -e "${GREEN}✓ yay is installed: $(yay --version)${NC}"

if [ -f "${AURLIST}" ]; then
    echo -e "${YELLOW}Installing AUR packages...${NC}"
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        echo -e "${BLUE}==>${NC} Installing AUR package: ${pkg}"
        yay -S --needed --noconfirm "$pkg" || echo -e "${YELLOW}Warning: Failed to install $pkg (may require manual intervention).${NC}"
    done < "${AURLIST}"
fi

echo -e "${GREEN}✓ AUR package setup complete!${NC}"
