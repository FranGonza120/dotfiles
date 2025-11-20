#!/bin/bash

echo "Instalando Hyprland y hyprpaper"
sudo dnf install -y hyprland hyprpaper polkit-gnome xdg-desktop-portal xdg-desktop-portal-hyprland
sudo dnf install -C -y pulseaudio pavucontrol blueman-applet mako waybar wofi brightnessctl grim wl-clipboard network-manager-applet unzip unrar

cp -r "$DOTFILES_DIR/hypr" "$CONFIG_DIR/" 
cp -r "$DOTFILES_DIR/mako" "$CONFIG_DIR/" 
cp -r "$DOTFILES_DIR/waybar" "$CONFIG_DIR/" 

echo "hyprland instalado correctamente"


