#!/bin/bash


echo "Instalando swayfx"
sudo dnf copr enable swayfx/swayfx 
sudo dnf install swayfx
echo "Instalando mako wofi waybar y otras utilidades para swayfx"
sudo dnf install mako wofi waybar brightnessctl grim wl-clipboard network-manager-applet blueman-applet unzip unrar

echo "Copiando archvos de configuración de sway, mako y waybar"
cp -r "$DOTFILES_DIR/sway" "$CONFIG_DIR/"
cp -r "$DOTFILES_DIR/mako" "$CONFIG_DIR/" 
cp -r "$DOTFILES_DIR/waybar" "$CONFIG_DIR/" 
