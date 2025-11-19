#!/bin/bash 
WALLPAPER_DIR="$HOME/Escritorio/3.Recursos/Imagenes/" 
SETTER="$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/set_wallpaper.sh"
mapfile -t FILES < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \)) # Limpiar prefijo para mostrar en Rofi 

PREFIX="$WALLPAPER_DIR" CLEANED_OPTIONS=("${FILES[@]/$PREFIX/}") 
CHOICE_INDEX=$(printf '%s\n' "${CLEANED_OPTIONS[@]}" | rofi -dmenu -p "Elegí fondo" -format i)

[ -z "$CHOICE_INDEX" ] && exit 0

SELECTED_FILE="${FILES[$CHOICE_INDEX]}"

"$SETTER" "$SELECTED_FILE"
