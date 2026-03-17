#!/bin/bash
if command -v hyprland >/dev/null 2>&1; then
    echo "Hyprland ya se encuentra instalado"
else
    echo "Instalando Hyprland y hyprpaper"
    sudo dnf copr enable solopasha/hyprland
    sudo dnf install -y hyprland hyprpaper hyprpolkitagent hyprland-qtutils xdg-desktop-portal xdg-desktop-portal-hyprland hyprsunset
    sudo dnf install -y blueman-applet mako waybar wofi fd brightnessctl grim wl-clipboard network-manager-applet unzip unrar
fi
echo "Creando links para carpetas de configuración de hyrpland, mako y waybar"

ln -snf "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr" 
ln -snf "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" 
ln -snf "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" 
ln -snf "$DOTFILES_DIR/wofi" "$CONFIG_DIR/wofi" 

echo "Hyprland instalado correctamente"
