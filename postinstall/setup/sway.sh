#!/bin/bash


echo "Instalando swayfx"
sudo dnf copr enable swayfx/swayfx 
sudo dnf install swayfx
echo "Instalando mako wofi waybar y otras utilidades para swayfx"
sudo dnf install mako wofi waybar brightnessctl grim wl-clipboard network-manager-applet blueman-applet unzip unrar

echo "Creando links para carpetas de configuración de sway, mako y waybar"
ln -snf "$DOTFILES_DIR/sway" "$CONFIG_DIR/sway"
ln -snf "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" 
ln -snf "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" 
ln -snf "$DOTFILES_DIR/wofi" "$CONFIG_DIR/wofi" 
