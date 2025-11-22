#!/bin/bash
if command -v hyprland >/dev/null 2>&1; then
    echo "Hyprland ya se encuentra instalado"
else
    echo "Instalando Hyprland y hyprpaper"
    sudo dnf copr enable solopasha/hyprland
    sudo dnf install -y hyprland hyprpaper hyprpolkitagent hyprland-qtutils xdg-desktop-portal xdg-desktop-portal-hyprland
    #sudo dnf install -y blueman-applet mako waybar wofi brightnessctl grim wl-clipboard network-manager-applet unzip unrar
fi
echo "Copiando archivos de configuración de hyrpland, mako y waybar"

cp -r "$DOTFILES_DIR/hypr" "$CONFIG_DIR/" 
cp -r "$DOTFILES_DIR/mako" "$CONFIG_DIR/" 
cp -r "$DOTFILES_DIR/waybar" "$CONFIG_DIR/" 

echo "hyprland instalado correctamente"
