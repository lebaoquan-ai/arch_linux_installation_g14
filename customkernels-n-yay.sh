#!/bin/bash

# Function to handle errors
handle_error() {
    echo "An error occurred. Exiting..."
    exit 1
}

# Trap any errors and call the handle_error function
trap 'handle_error' ERR

# Import and sign the GPG key
echo "Importing and signing the GPG key..."
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || handle_error
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || handle_error
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || handle_error
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35 || handle_error

echo "Adding [g14] repository to /etc/pacman.conf..."
if ! grep -q "\[g14\]" /etc/pacman.conf; then
    echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a /etc/pacman.conf || handle_error
else
    echo "[g14] repository already exists in /etc/pacman.conf."
fi

# Sync package databases
echo "Syncing package databases..."
sudo pacman -Sy --noconfirm || handle_error

# Install linux-g14 and linux-g14-headers
echo "Installing linux-g14 and linux-g14-headers..."
sudo pacman -S --noconfirm linux-g14 linux-g14-headers || handle_error

# Update GRUB configuration
echo "Updating GRUB configuration..."
sudo grub-mkconfig -o /boot/grub/grub.cfg || handle_error

# Perform a full system upgrade
echo "Performing a full system upgrade..."
sudo pacman -Suy --noconfirm || handle_error

echo "Custom kernel installation and system update completed successfully!"

echo "Installing some essential packages"
sudo pacman -S networkmanager base-devel git zip tar amd-ucode

echo "Installing ROG Control Center"
sudo pacman -S asusctl power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon.service
sudo pacman -S supergfxctl switcheroo-control
sudo systemctl enable --now supergfxd
sudo systemctl enable --now switcheroo-control

echo "Installing Yay"
sudo pacman -S --needed git base-devel 
git clone https://aur.archlinux.org/yay.git 
cd yay && makepkg -si



