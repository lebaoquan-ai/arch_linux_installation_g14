#!/usr/bin/env bash
# ==============================================================================
# 6-make-timeshift-snapshot.sh
# Installs Timeshift (if not present) and creates a baseline system snapshot.
# Requires root privileges (sudo).
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be executed with root privileges (sudo).${NC}" >&2
    echo -e "Please run: ${BOLD}sudo $0${NC}" >&2
    exit 1
fi

echo -e "${BLUE}==>${NC} Setting up Timeshift & System Snapshot..."

# 1. Install Timeshift and prerequisites if missing
if ! command -v timeshift &>/dev/null; then
    echo -e "${YELLOW}Timeshift not found. Installing timeshift, btrfs-progs, and cronie...${NC}"
    pacman -S --needed --noconfirm timeshift cronie btrfs-progs
    systemctl enable --now cronie.service || true
fi

echo -e "${GREEN}✓ Timeshift installed: $(timeshift --version 2>/dev/null || echo "ready")${NC}"

# 2. Check filesystem type
ROOT_FSTYPE=$(findmnt -n -o FSTYPE /)
echo -e "${CYAN}Root filesystem detected:${NC} ${ROOT_FSTYPE}"

SNAPSHOT_COMMENT="Baseline PC Setup - $(date '+%Y-%m-%d %H:%M:%S')"

# 3. Create snapshot
echo -e "${YELLOW}Creating snapshot with description: \"${SNAPSHOT_COMMENT}\"...${NC}"
if [ "${ROOT_FSTYPE}" = "btrfs" ]; then
    echo -e "${BLUE}Using high-performance BTRFS subvolume snapshot mode...${NC}"
    timeshift --create --comments "${SNAPSHOT_COMMENT}" --tags O
else
    echo -e "${BLUE}Using RSYNC snapshot mode...${NC}"
    timeshift --create --comments "${SNAPSHOT_COMMENT}" --tags O
fi

echo -e "${GREEN}✓ Snapshot created successfully!${NC}"
echo ""
echo -e "${BOLD}Current Timeshift Snapshots:${NC}"
timeshift --list || true
