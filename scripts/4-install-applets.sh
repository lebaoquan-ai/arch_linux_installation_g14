#!/usr/bin/env bash
# ==============================================================================
# 4-install-applets.sh
# Installs COSMIC custom applets & utility binaries into ~/.local/bin/
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Installing COSMIC custom applets to ~/.local/bin..."

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"

install_github_binary() {
    local name="$1"
    local repo="$2"
    local tag="$3"
    local asset_pattern="$4"
    
    if [ -x "${BIN_DIR}/${name}" ]; then
        echo -e "${GREEN}✓ ${name} is already installed in ${BIN_DIR}${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Downloading ${name} (${tag}) from ${repo}...${NC}"
    local download_url
    download_url=$(curl -s "https://api.github.com/repos/${repo}/releases/tags/${tag}" \
        | jq -r ".assets[] | select(.name | test(\"${asset_pattern}\")) | .browser_download_url" | head -n 1)

    if [ -n "${download_url}" ] && [ "${download_url}" != "null" ]; then
        local tmp_file
        tmp_file=$(mktemp)
        curl -fsSL "${download_url}" -o "${tmp_file}"
        if file "${tmp_file}" | grep -q "gzip compressed"; then
            tar -xzf "${tmp_file}" -C "${BIN_DIR}" "${name}" 2>/dev/null || tar -xzf "${tmp_file}" -C "${BIN_DIR}"
        elif file "${tmp_file}" | grep -q "Zip archive"; then
            unzip -o -d "${BIN_DIR}" "${tmp_file}"
        else
            mv "${tmp_file}" "${BIN_DIR}/${name}"
        fi
        chmod +x "${BIN_DIR}/${name}"
        rm -f "${tmp_file}"
        echo -e "${GREEN}✓ Installed ${name}${NC}"
    else
        echo -e "${YELLOW}Warning: Could not fetch prebuilt release for ${name}. You can build it from source at https://github.com/${repo}${NC}"
    fi
}

# 1. cbar (Scriptable panel applet)
if [ ! -x "${BIN_DIR}/cbar" ]; then
    install_github_binary "cbar" "alexandreprates/cbar" "v1.4.4" "cbar.*x86_64.*linux|cbar.*linux"
fi

# 2. cosmic-applet-arch (Arch package update monitor)
if [ ! -x "${BIN_DIR}/cosmic-applet-arch" ]; then
    install_github_binary "cosmic-applet-arch" "nick42d/cosmic-applet-arch" "v1.1.1" "cosmic-applet-arch"
fi

# 3. cosmic-ext-applet-caffeine (Inhibit sleep/suspend applet)
if [ ! -x "${BIN_DIR}/cosmic-ext-applet-caffeine" ]; then
    install_github_binary "cosmic-ext-applet-caffeine" "tropicbliss/cosmic-ext-applet-caffeine" "v0.1.8" "caffeine"
fi

# 4. tiling-assistant (Cosmic auto-tiling exceptions manager)
if [ ! -x "${BIN_DIR}/tiling-assistant" ]; then
    install_github_binary "tiling-assistant" "maugustoldo/cosmic-tiling-manager" "v1.1.1" "tiling-assistant"
fi

echo -e "${GREEN}✓ COSMIC applets verification complete!${NC}"
