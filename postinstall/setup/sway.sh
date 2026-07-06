#!/bin/bash


echo "Instalando swayfx"
sudo dnf install sway
echo "Instalando otras utilidades para sway"
sudo dnf install brightnessctl grim wl-clipboard network-manager-applet blueman-applet unzip unrar

echo "Creando links para carpetas de configuración de sway, mako y waybar"
ln -snf "$DOTFILES_DIR/sway" "$CONFIG_DIR/sway"
