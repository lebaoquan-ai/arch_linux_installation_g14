#!/usr/bin/env bash
# ==============================================================================
# setup.sh
# Master Provisioning & Migration Orchestrator for Arch Linux Setup
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BOLD}       Arch Linux + COSMIC Desktop Migration & Setup Tool       ${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "Device Setup: ASUS ROG Zephyrus G14 / Polyglot Arch Linux"
    echo ""
}

show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  --all         Execute full provisioning (Packages, AUR, Dev, Applets, Configs, GitHub)"
    echo "  --packages    Install official Pacman packages"
    echo "  --aur         Install yay and AUR packages"
    echo "  --dev         Setup mise polyglot runtimes (Node, Python, gh) & pipx"
    echo "  --applets     Install COSMIC custom applets (cbar, caffeine, arch, tiling)"
    echo "  --configs     Deploy dotfiles and application configurations"
    echo "  --backup      Re-sync system configs back into this setup folder"
    echo "  --github      Configure git identity, SSH key, and GitHub authentication"
    echo "  --snapshot    Install Timeshift and create a system snapshot (requires sudo)"
    echo "  --help        Show this help message"
    echo ""
}

run_packages() {
    bash "${REPO_ROOT}/scripts/1-install-pacman.sh"
}

run_aur() {
    bash "${REPO_ROOT}/scripts/2-install-yay-and-aur.sh"
}

run_dev() {
    bash "${REPO_ROOT}/scripts/3-setup-mise-and-dev.sh"
}

run_applets() {
    bash "${REPO_ROOT}/scripts/4-install-applets.sh"
}

run_configs() {
    bash "${REPO_ROOT}/configs/restore-configs.sh"
}

run_backup() {
    bash "${REPO_ROOT}/configs/backup-configs.sh"
}

run_github() {
    bash "${REPO_ROOT}/scripts/5-setup-github.sh"
}

run_snapshot() {
    sudo bash "${REPO_ROOT}/scripts/6-make-timeshift-snapshot.sh"
}

show_banner

if [ $# -eq 0 ]; then
    echo -e "${YELLOW}No option specified. Choose an action:${NC}"
    echo "1) Full Setup (--all)"
    echo "2) Install Pacman Packages"
    echo "3) Install AUR Packages"
    echo "4) Setup Dev Tools (mise, Node, Python, pipx)"
    echo "5) Install COSMIC Applets"
    echo "6) Deploy Configurations & Dotfiles"
    echo "7) Connect Local GitHub (SSH & gh CLI)"
    echo "8) Take Timeshift Snapshot"
    echo "9) Backup Current System Configs to Repo"
    echo "q) Quit"
    echo ""
    read -r -p "Enter choice [1-9/q]: " CHOICE
    case "${CHOICE}" in
        1)
            run_packages
            run_aur
            run_dev
            run_applets
            run_configs
            run_github
            ;;
        2) run_packages ;;
        3) run_aur ;;
        4) run_dev ;;
        5) run_applets ;;
        6) run_configs ;;
        7) run_github ;;
        8) run_snapshot ;;
        9) run_backup ;;
        *) exit 0 ;;
    esac
    exit 0
fi

case "$1" in
    --all)
        run_packages
        run_aur
        run_dev
        run_applets
        run_configs
        run_github
        ;;
    --packages) run_packages ;;
    --aur) run_aur ;;
    --dev) run_dev ;;
    --applets) run_applets ;;
    --configs) run_configs ;;
    --backup) run_backup ;;
    --github) run_github ;;
    --snapshot) run_snapshot ;;
    --help|-h) show_usage ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        show_usage
        exit 1
        ;;
esac
