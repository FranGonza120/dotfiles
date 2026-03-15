#!/bin/bash

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

echo "✅ Limpieza completa."

