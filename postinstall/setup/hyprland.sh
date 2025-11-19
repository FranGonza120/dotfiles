!#/bin/bash

echo "Instalando Hyprland y hyprpaper"
sudo dnf install -C -y hyprland hyprpaper pulseaudio pavucontrol nm-applet blueman-applet mako waybar wofi polkit-gnome xdg-desktop-portal xdg-desktop-portal-hyprland brightnessctl grim wl-clipboard

cp -r "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr" 
cp -r "$DOTFILES_DIR/mako" "$CONFIG_DIR/mako" 
cp -r "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" 

echo "hyprland instalado correctamente"


