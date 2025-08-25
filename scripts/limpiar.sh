#!/bin/bash
echo "🔧 Limpiando paquetes..."
sudo dnf autoremove -y
sudo dnf clean all

echo "🧹 Limpiando cachés..."
sudo journalctl --vacuum-time=7d
sudo rm -rf ~/.cache/thumbnails/*

echo "✅ Optimización completa."

