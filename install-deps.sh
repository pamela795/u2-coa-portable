#!/bin/bash
# u2-coa-portable/install-deps.sh (run once on target machine)
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER

# NVIDIA Container Toolkit (Ubuntu 26.04)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/ubuntu22.04/$(. /etc/os-release && echo "$VERSION_CODENAME")/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "Please log out and back in for Docker group changes to take effect."
