# Comprehensive System & Package Architecture Summary

This document provides a complete breakdown of the software stack, runtime environments, desktop configuration, and hardware integration on this machine (**ASUS ROG Zephyrus G14 GA402XV** running **Arch Linux** with **COSMIC Desktop**).

---

## 1. Operating System & Kernel Foundation

| Component | Implementation | Notes |
| :--- | :--- | :--- |
| **Distribution** | Arch Linux (Rolling Release) | Minimalist baseline installed via `archinstall` |
| **Kernel** | `linux` 7.2.11.arch1-1 | High-performance monolithic Linux kernel |
| **Filesystem** | Btrfs on NVMe (`nvme0n1p2`) | Subvolumes: `/@` (root), `/@home`, `/@pkg`, `/@log` |
| **Bootloader** | UEFI with `efibootmgr` | Fast system initialization |
| **Microcode & Firmware** | `amd-ucode`, `linux-firmware`, `sof-firmware` | CPU errata mitigations, GPU & Sound Open Firmware support |
| **Memory Optimization** | `zram-generator` | Compressed RAM swap device (`/dev/zram0`) |

---

## 2. Hardware & Laptop Integration (ASUS ROG + NVIDIA Hybrid)

| Subsystem | Packages | Role & Purpose |
| :--- | :--- | :--- |
| **Laptop Control & Power** | `asusctl`, `rog-control-center`, `power-profiles-daemon` | Manages fan curves, GPU modes (Integrated/Hybrid/Dedicated), charge threshold (e.g. 80%), and keyboard RGB. |
| **NVIDIA Compute & Graphics** | `nvidia-utils`, `cuda`, `nvidia-laptop-power-cfg` | NVIDIA userspace driver, CUDA toolkit, and dynamic D3 cold runtime power management for extended battery life. |
| **Integrated Intel/AMD Graphics** | `xf86-video-amdgpu`, `vulkan-radeon`, `vulkan-intel`, `intel-media-driver`, `libva-intel-driver`, `libvpl`, `vpl-gpu-rt` | Hardware accelerated video encode/decode (VA-API / QSV) and Vulkan rendering on the internal GPU. |

---

## 3. Desktop Environment: System76 COSMIC Desktop

The system runs System76's next-generation Rust-based **COSMIC Desktop Environment** natively under Wayland.

- **Compositor & Session:** `cosmic-comp`, `cosmic-session`
- **Shell & Navigation:** `cosmic-panel`, `cosmic-applets`, `cosmic-launcher`, `cosmic-workspaces`, `cosmic-app-library`
- **Core Applications:** `cosmic-files`, `cosmic-terminal`, `cosmic-text-editor`, `cosmic-settings`, `cosmic-store`, `cosmic-viewer`, `cosmic-player`
- **System Portal & UI:** `xdg-desktop-portal-cosmic`, `cosmic-greeter`, `cosmic-osd`, `cosmic-notifications`
- **Custom Panel Enhancements (`~/.local/bin/`):**
  - **`cbar` (v1.4.4):** Interactive top-bar scripts (`calendar.30s.sh` for Google Calendar/Meet, `screenrecord.1s.sh` for screen capture, `todo.5s.sh` for fast task tracking).
  - **`cosmic-applet-arch` (v1.1.1):** Live indicator for pacman and AUR updates.
  - **`cosmic-ext-applet-caffeine` (v0.1.8):** Toggle to inhibit display sleep and system suspension.
  - **`tiling-assistant` (v1.1.1):** Window exception rule manager for COSMIC's auto-tiling engine.

---

## 4. Audio, Network, Printing & Input Stack

- **Audio Stack:** `pipewire`, `wireplumber`, `pipewire-pulse`, `pipewire-alsa`, `pipewire-jack`, `gst-plugin-pipewire` (Modern unified low-latency audio server).
- **Networking & Bluetooth:** `networkmanager`, `network-manager-applet`, `wpa_supplicant`, `bluez`, `bluez-utils`.
- **Printing Services:** `cups`, `cups-pk-helper`, `ghostscript`, `system-config-printer`.
- **Vietnamese Input Engine:** `fcitx5`, `fcitx5-bamboo`, `fcitx5-configtool`, `fcitx5-gtk`, `fcitx5-qt` (Clean Vietnamese typing under Wayland).
- **Typography:** `ttf-jetbrains-mono-nerd`, `noto-fonts-cjk`, `noto-fonts-emoji`.

---

## 5. Developer Runtimes, CLI & Productivity Ecosystem

- **Developer Tool Version Manager (`mise`):**
  - Node.js: `24.22.1` (`lts`)
  - Python: `3.11.17` (`3.11`)
  - GitHub CLI: `gh` (v2.103.0)
- **Isolated Python CLI Apps (`pipx`):**
  - `hermes-agent` (v0.15.2) — AI agent runner (`hermes`, `hermes-acp`, `hermes-agent`)
- **Shells & Modern Command Line:**
  - `fish 4.9` (Interactive default shell) & `bash`
  - `fastfetch`, `btop`, `htop`, `eza` (modern ls), `ripgrep` (ultra-fast grep), `fzf` (fuzzy finder), `zoxide` (smart cd), `jq`, `unzip`, `wget`
- **Code Editors & Review:**
  - `neovim 0.12`: Configured with dynamic background transparency matching COSMIC Terminal, `diffview.nvim` for code review, `gitsigns.nvim`, `fzf-lua`, `treesitter`, `render-markdown`, and `mason.nvim` language servers (`rust-analyzer`, `pyright`, `marksman`).
  - `zed 1.25`: GPU-accelerated editor.
- **Media Creation & Web Browsers:**
  - Browsers: `firefox`, `chromium`, `opera`
  - Video Production: `obs-studio`, `kdenlive`
  - Cloud Accounts: `gnome-calendar`, `gnome-online-accounts`, `gnome-online-accounts-gtk`, `evolution-data-server`, `gnome-keyring`, `seahorse`.
