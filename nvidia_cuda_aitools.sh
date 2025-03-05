#!/bin/bash

# Exit on any error
set -e

echo "Starting installation of NVIDIA drivers, CUDA, and Llama.cpp + Ollama on Arch Linux..."

# Step 1: Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Step 1.9: 

sudo pacman -S --needed base-devel git 

# Ensure yay is installed
if ! command -v yay &>/dev/null; then
    echo "yay not found. Installing..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Step 2: Install NVIDIA drivers with DKMS (dynamic kernel module support)
echo "Installing NVIDIA drivers with DKMS..."
yay -S nvidia-dkms nvidia-utils opencl-nvidia --noconfirm


# Step 2.5 [[recommended for nvidia drivers and graphics switching to work
# properly]]

# set kernel parameters 

echo "Configuring GRUB for NVIDIA..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& nvidia-drm.modeset=1 nvidia-drm.fbdev=1/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# early loading of nvidia modules
#
echo "Configuring early loading of NVIDIA modules..."
sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
sudo sed -i 's/kms//' /etc/mkinitcpio.conf
sudo mkinitcpio -P
Add Early Loading of NVIDIA Modules:



# Adding the Pacman Hook:

	## Get the nvidia.hook -file from this repository

echo "Setting up pacman hook for NVIDIA updates..."
mkdir -p ~/nvidia-setup
cd ~/nvidia-setup
wget https://raw.githubusercontent.com/korvahannu/arch-nvidia-drivers-installation-guide/main/nvidia.hook
sudo mkdir -p /etc/pacman.d/hooks/
sudo mv nvidia.hook /etc/pacman.d/hooks/
# sudo nvim /etc/pacman.d/hooks/nvidia.hook

# Automate editing of the hook file
sudo sed -i 's/=nvidia/=nvidia-dkms/' /etc/pacman.d/hooks/nvidia.hook
sudo sed -i 's/=linux/=linux-g14/' /etc/pacman.d/hooks/nvidia.hook


cd ~
rm -rf ~/nvidia-setup		

# Step 3: Install the CUDA toolkit
echo "Installing CUDA Toolkit..."
yay -S cuda 

# Step 3.5: add CUDA 12.8 to PATH
#
echo "Configuring CUDA environment variables..."
echo 'export PATH=/opt/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64\
                         ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'
source ~/.bashrc

# Step 4: Install additional libraries needed for building Llama.cpp and Ollama
echo "Installing dependencies for Llama.cpp and Ollama..."
sudo pacman -S --needed base-devel git cmake gcc --noconfirm

# Step 5: Clone the llama.cpp repository from GitHub
echo "Cloning llama.cpp repository..."
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp

# Step 6: Build llama.cpp with CUDA 
echo "Building llama.cpp..."

cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release
make -j$(nproc) 

# Step 7: Ollama 
curl -fsSL https://ollama.com/install.sh | sh

# Step 8: installing Docker  
#
echo "Installing Docker and LazyDocker..."
sudo pacman -S docker lazydocker --noconfirm
sudo systemctl enable --now docker

echo "give privilege to current user"
sudo usermod -aG docker $USER

# step 9: Open-webui with CUDA (in Docker) 
# just pull image without running 
docker pull ghcr.io/open-webui/open-webui:cuda 

# Step 10: 

# Step 11: Reboot to apply kernel module changes
echo "Installation complete. Please reboot your system for changes to take effect."

