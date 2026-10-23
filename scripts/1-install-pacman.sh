#!/usr/bin/env bash
# ==============================================================================
# 1-install-pacman.sh
# Installs all official repository packages for the Arch Linux setup.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PKGLIST="${REPO_ROOT}/pkglist/pacman-all.txt"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Installing official packages via pacman..."

if [ ! -f "${PKGLIST}" ]; then
    echo -e "${RED}Error: Package list not found at ${PKGLIST}${NC}" >&2
    exit 1
fi

echo -e "${YELLOW}Updating package databases...${NC}"
sudo pacman -Sy

echo -e "${YELLOW}Installing $(wc -l < "${PKGLIST}") packages (skipping already installed)...${NC}"
sudo pacman -S --needed --noconfirm - < "${PKGLIST}"

echo -e "${GREEN}✓ All official packages are installed successfully!${NC}"
