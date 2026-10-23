#!/usr/bin/env bash
# ==============================================================================
# 5-setup-github.sh
# Connects local environment to GitHub via SSH and GitHub CLI (gh).
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Setting up Git & GitHub connection..."

# 1. Ensure gh is available
if ! command -v gh &>/dev/null; then
    if [ -f "${HOME}/.local/share/mise/shims/gh" ]; then
        export PATH="${HOME}/.local/share/mise/shims:${PATH}"
    else
        echo -e "${YELLOW}Installing gh CLI via mise...${NC}"
        mise use -g gh@latest
    fi
fi

# 2. Configure Git User Identity if not set
CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [ -z "${CURRENT_NAME}" ] || [ -z "${CURRENT_EMAIL}" ]; then
    echo -e "${YELLOW}Git user identity is not fully configured.${NC}"
    if [ -t 0 ]; then
        read -r -p "Enter your Git Name [default: Bao Quan]: " GIT_NAME
        GIT_NAME="${GIT_NAME:-Bao Quan}"
        read -r -p "Enter your Git Email [e.g. you@example.com]: " GIT_EMAIL
    else
        GIT_NAME="Bao Quan"
        GIT_EMAIL="lebaoquan@users.noreply.github.com"
    fi
    git config --global user.name "${GIT_NAME}"
    git config --global user.email "${GIT_EMAIL}"
    echo -e "${GREEN}✓ Configured git user.name: ${GIT_NAME}, user.email: ${GIT_EMAIL}${NC}"
else
    echo -e "${GREEN}✓ Git user: ${CURRENT_NAME} <${CURRENT_EMAIL}>${NC}"
fi

git config --global init.defaultBranch main
git config --global pull.rebase false

# 3. SSH Key Verification / Generation
SSH_KEY="${HOME}/.ssh/id_ed25519"
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if [ ! -f "${SSH_KEY}" ]; then
    echo -e "${YELLOW}Generating new ED25519 SSH key for GitHub...${NC}"
    ssh-keygen -t ed25519 -C "${CURRENT_EMAIL:-lebaoquan@github}" -f "${SSH_KEY}" -N ""
    chmod 600 "${SSH_KEY}"
    chmod 644 "${SSH_KEY}.pub"
    echo -e "${GREEN}✓ Generated SSH key at ${SSH_KEY}${NC}"
else
    echo -e "${GREEN}✓ SSH key exists at ${SSH_KEY}${NC}"
fi

PUB_KEY=$(cat "${SSH_KEY}.pub")

# 4. GitHub CLI Authentication
echo -e "${CYAN}------------------------------------------------------------${NC}"
echo -e "${BOLD}Your SSH Public Key is:${NC}"
echo -e "${YELLOW}${PUB_KEY}${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"

if gh auth status &>/dev/null; then
    echo -e "${GREEN}✓ GitHub CLI is already authenticated!${NC}"
    gh auth status
else
    echo -e "${YELLOW}GitHub CLI is not logged in.${NC}"
    echo -e "To authenticate with your GitHub account, run:"
    echo -e "  ${BOLD}gh auth login -p ssh -w${NC}"
    echo ""
    echo -e "This will:"
    echo -e "  1. Open a browser window to authenticate with GitHub"
    echo -e "  2. Automatically upload your SSH public key (~/.ssh/id_ed25519.pub)"
    echo -e "  3. Configure git credential helpers"
    
    if [ -t 0 ]; then
        read -r -p "Do you want to run 'gh auth login' now? [Y/n] " RESP
        case "$RESP" in
            [nN][oO]|[nN])
                echo "Skipping interactive login for now."
                ;;
            *)
                gh auth login -p ssh -w
                ;;
        esac
    fi
fi

# 5. Test connection
echo -e "${BLUE}==>${NC} Testing GitHub SSH connection..."
ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true
