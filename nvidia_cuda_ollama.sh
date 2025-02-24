#!/bin/bash

# Exit on any error
set -e

echo "Starting installation of NVIDIA drivers, CUDA, and Llama.cpp + Ollama on Arch Linux..."

# Step 1: Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Step 2: Install NVIDIA drivers with DKMS (dynamic kernel module support)
echo "Installing NVIDIA drivers with DKMS..."
sudo pacman -S nvidia-dkms nvidia-utils --noconfirm

# Step 3: Install the CUDA toolkit
echo "Installing CUDA Toolkit..."
sudo pacman -S cuda --noconfirm

# Step 4: Install additional libraries needed for building Llama.cpp and Ollama
echo "Installing dependencies for Llama.cpp and Ollama..."
sudo pacman -S base-devel git cmake libomp --noconfirm

# Step 5: Clone the llama.cpp repository from GitHub
echo "Cloning llama.cpp repository..."
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp

# Step 6: Build llama.cpp
echo "Building llama.cpp..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)

# Step 7: Clone the Ollama repository from GitHub (adjust if a specific repo version is needed)
echo "Cloning Ollama repository..."
cd ~
git clone https://github.com/ollama/ollama.git
cd ollama

# Step 8: Build Ollama
echo "Building Ollama..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)

# Step 9: Install Ollama and set up environment variables
echo "Installing Ollama..."
sudo make install

# Step 10: Set up environment variables for CUDA (if not already set)
echo "Setting up environment variables for CUDA..."
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Step 11: Reboot to apply kernel module changes
echo "Installation complete. Please reboot your system for changes to take effect."

