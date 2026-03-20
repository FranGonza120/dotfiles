#!/bin/bash
echo "🔧 Limpiando paquetes..."
sudo dnf autoremove -y
sudo dnf clean all

echo "🧹 Limpiando cachés..."
sudo journalctl --vacuum-time=7d
sudo rm -rf ~/.cache/thumbnails/*

echo "✅ Optimización completa."
echo "📦 Iniciando limpieza de Flatpak..."

# 1. Eliminar apps y runtimes no usados
echo "🧹 Eliminando apps/runtimes huérfanos..."
sudo flatpak uninstall --unused -y

# 2. Reparar y eliminar objetos inconsistentes
echo "🔧 Reparando instalación de Flatpak (puede tardar unos minutos)..."
sudo flatpak repair

# 3. Limpiar caché de descargas temporales
echo "🗑️ Borrando cachés temporales..."
rm -rf ~/.var/app/*/cache/*
rm -rf ~/.local/share/flatpak/system-cache/*

# 4. Mostrar espacio actual usado por Flatpak
echo "📊 Espacio ocupado por objetos Flatpak:"
sudo du -sh /var/lib/flatpak/repo/objects

echo "✅ Limpieza de Flatpak completa."

echo "Iniciando BleachBit"
xhost si:localuser:root
sudo bleachbit
xhost -si:localuser:root
echo "Se removieron los permisos para iniciar bleachbit"
echo "✅ Limpieza General completa."
