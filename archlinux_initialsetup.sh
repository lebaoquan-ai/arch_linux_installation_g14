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

# Add [g14] repository to /etc/pacman.conf
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

# Install essential packages
echo "Installing some essential packages..."
sudo pacman -S --noconfirm networkmanager base-devel git zip tar amd-ucode || handle_error

# Install ROG Control Center
echo "Installing ROG Control Center..."
sudo pacman -S --noconfirm asusctl power-profiles-daemon supergfxctl switcheroo-control || handle_error
sudo systemctl enable --now power-profiles-daemon.service || handle_error
sudo systemctl enable --now supergfxd || handle_error
sudo systemctl enable --now switcheroo-control || handle_error

# Install Yay (AUR helper)
echo "Installing Yay..."
sudo pacman -S --needed git base-devel || handle_error
git clone https://aur.archlinux.org/yay.git || handle_error
cd yay && makepkg -si --noconfirm || handle_error
cd .. && rm -rf yay || handle_error

# Install Timeshift and create a backup point
echo "Installing Timeshift and dependencies..."
sudo pacman -S --noconfirm timeshift || handle_error

# Check if Timeshift is installed
if ! command -v timeshift &> /dev/null; then
    echo "Timeshift installation failed. Exiting..."
    exit 1
fi

# Create a backup point
echo "Creating a backup point with Timeshift..."
sudo timeshift --create --comments "Initial backup point" || handle_error

# Display backup information
echo "Backup point created successfully!"
sudo timeshift --list

echo "Timeshift installation and initial backup completed successfully!"

# Install Kitty (terminal emulator)
echo "Installing Kitty..."
sudo pacman -S --noconfirm kitty || handle_error

# Install Zen Browser
echo "Installing Zen Browser..."
yay -S --noconfirm zen-browser || handle_error

# Install Yazi (file manager)
echo "Installing Yazi..."
yay -S --noconfirm yazi || handle_error

# Install Nemo (file manager)
echo "Installing Nemo..."
sudo pacman -S --noconfirm nemo || handle_error

echo "All installations completed successfully!"
