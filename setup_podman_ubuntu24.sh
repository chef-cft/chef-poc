#!/bin/bash

set -e

echo "🔧 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "📦 Installing Podman and dependencies..."
sudo apt install -y podman podman-docker curl jq

echo "🔌 Enabling Podman Docker-compatible socket..."
if systemctl --user status podman.socket >/dev/null 2>&1; then
  systemctl --user enable --now podman.socket
else
  sudo systemctl enable --now podman.socket
fi

echo "🌐 Setting Docker-compatible environment variable..."
export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock
if ! grep -q 'export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock' ~/.bashrc; then
  echo 'export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock' >> ~/.bashrc
fi

echo "📝 Configuring registries.conf to include Docker Hub..."
mkdir -p ~/.config/containers
cat <<EOF > ~/.config/containers/registries.conf
unqualified-search-registries = ["docker.io", "quay.io", "ghcr.io"]

[[registry]]
location = "docker.io"
EOF

echo "🔍 Searching for CNI .conflist files to patch..."
CNI_DIR="$HOME/.config/cni/net.d"
if [ -d "$CNI_DIR" ]; then
  find "$CNI_DIR" -name '*.conflist' -exec sed -i 's/"cniVersion": "1.0.0"/"cniVersion": "0.4.0"/g' {} +
  echo "✅ Patched CNI config files in $CNI_DIR"
else
  echo "⚠️ No CNI config directory found at $CNI_DIR"
fi

echo "♻️ Resetting Podman system to apply changes..."
podman system reset -f || true
podman system renumber || true

echo "✅ Podman setup complete. You can now use it with kitchen-dokken."
