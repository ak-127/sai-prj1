#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "======================================"
echo "🚀 Starting Docker + Jenkins Installer"
echo "======================================"

echo ""
echo "📦 [1/10] Updating system packages..."
sudo apt update && sudo apt upgrade -y
echo "✅ System updated successfully."

echo ""
echo "📦 [2/10] Installing required dependencies..."
sudo apt install -y ca-certificates curl gnupg
echo "✅ Dependencies installed."

echo ""
echo "🔐 [3/10] Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "✅ Docker GPG key added."

echo ""
echo "📁 [4/10] Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "✅ Docker repository added."

echo ""
echo "📦 [5/10] Installing Docker Engine..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
echo "✅ Docker installed successfully."

echo ""
echo "🐳 [6/10] Installing Docker Compose..."
LATEST_COMPOSE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "✅ Docker Compose installed."

echo ""
echo "⚙️ [7/10] Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker
echo "✅ Docker service started."

echo ""
echo "☕ [8/10] Installing Java (required for Jenkins)..."
sudo apt install -y fontconfig openjdk-21-jre
echo "✅ Java installed."

echo ""
echo "🔑 [9/10] Installing Jenkins..."
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "✅ Jenkins installed and started."

echo ""
echo "👤 [10/10] Adding $USER and jenkin user to docker group..."
sudo usermod -aG docker $USER && sudo usermod -aG docker jenkin 
newgrp docker
echo "ℹ️  You may need to log out and log back in for group changes to apply."

echo ""
echo "======================================"
echo "🎉 Installation Complete!"
echo "--------------------------------------"
echo "Docker Version: $(docker --version)"
echo "Docker Compose Version: $(docker-compose --version)"
echo "Jenkins Status:"
sudo systemctl status jenkins --no-pager
echo "======================================"
