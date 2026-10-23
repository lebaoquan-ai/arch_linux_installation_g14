# Arch Linux Setup & Machine Migration Suite

This repository contains reproducible scripts, package declarations, and configurations to replicate the current PC setup (**Arch Linux + COSMIC Desktop + Dev Tooling + ASUS ROG Integration**) on a fresh machine or after a clean reinstall.

---

## 🚀 Quick Start on a Fresh Machine

### 1. Clone this repository (or copy it to your new system)
```bash
git clone git@github.com:lebaoquan-ai/arch_linux_installation_g14.git ~/arch_linux_installation_g14
cd ~/arch_linux_installation_g14
```

### 2. Run the Full Provisioning Script
```bash
./setup.sh --all
```
This runs the complete pipeline:
1. Installs all 116 official Pacman packages (`base`, `cosmic`, `pipewire`, drivers, etc.)
2. Installs `yay` and AUR packages (`opera`, `clipboard-manager-git`, `nvidia-laptop-power-cfg`)
3. Configures polyglot developer runtimes via `mise` (Node.js LTS, Python 3.11, GitHub CLI `gh`) and `pipx` (`hermes-agent`)
4. Verifies and deploys COSMIC desktop custom applets (`cbar`, `caffeine`, `arch-updates`, `tiling-assistant`)
5. Restores all dotfiles (`~/.config/nvim`, `~/.config/fish`, `~/.config/cbar`, `~/.config/fcitx5`, `~/.local/share/applications`)
6. Guides you through connecting GitHub with SSH and GitHub CLI (`gh`).

---

## 🛠 Modular Usage

You can also run individual steps as needed:

| Command | Action |
| :--- | :--- |
| `./setup.sh --packages` | Installs official Pacman packages from `pkglist/pacman-all.txt` |
| `./setup.sh --aur` | Installs `yay` and AUR packages from `pkglist/aur-apps.txt` |
| `./setup.sh --dev` | Sets up developer runtimes (`mise` Node/Python/gh, `pipx`) |
| `./setup.sh --applets` | Installs COSMIC custom applets into `~/.local/bin` |
| `./setup.sh --configs` | Deploys all dotfiles from `configs/` into your home directory |
| `./setup.sh --github` | Configures Git identity, ED25519 SSH key, and connects to GitHub |
| `./setup.sh --snapshot` | Installs Timeshift and creates a baseline system snapshot |
| `./setup.sh --backup` | Re-syncs current active system dotfiles back into this repo |

---

## 🛡 System Snapshot & Backup (Timeshift)

The system filesystem is formatted as Btrfs with standard subvolumes:
- `/@` (root system)
- `/@home` (user home directory)

To take an instant copy-on-write snapshot:
```bash
sudo ./scripts/6-make-timeshift-snapshot.sh
```
Or directly:
```bash
sudo timeshift --create --comments "Baseline PC Setup" --tags O
```
Snapshots can be restored anytime via the GUI (`timeshift-gtk`) or CLI (`sudo timeshift --restore`).

---

## 🔑 GitHub Connection Details

- **SSH Public Key:** Located at `~/.ssh/id_ed25519.pub`
- **GitHub CLI:** Installed and accessible via `gh`
- To link your GitHub account and upload your key in one step:
  ```bash
  gh auth login -p ssh -w
  ```
