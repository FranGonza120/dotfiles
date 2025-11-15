#!/bin/bash

WALLPAPER_DIR="$HOME/Escritorio/3.Recursos/Imagenes/"
SETTER="$HOME/Escritorio/3.Recursos/Scripts/config/set_wallpaper_hyprpaper.sh"

menu() {
    find "${WALLPAPER_DIR}" -type f -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | awk '{print "img:"$0}'
}


# Mostrar en Wofi y obtener selección
CHOICE=$(menu | wofi -c ~/.config/wofi/wallpaper -s ~/.config/wofi/wallpaper.css --show dmenu --prompt "Elegí fondo")

echo $CHOICE
# Si no eligió nada, salir
[ -z "$CHOICE" ] && exit 0

# Encontrar índice seleccionado

WALLPAPER_PATH="${CHOICE#img:}"

# Ejecutar el setter con la ruta completa
"$SETTER" "$WALLPAPER_PATH"
