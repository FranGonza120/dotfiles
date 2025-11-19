#!/bin/bash

THEME_DIR="$HOME/Escritorio/3.Recursos/dotfiles/Temas"
SET_THEME="$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/set_theme.sh"

# Obtener lista de carpetas (nombres de temas)
themes=$(find "$THEME_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Mostrar en rofi
chosen=$(echo "$themes" | rofi -dmenu -p "Elegir tema")

# Si seleccionó uno, aplicarlo
if [ -n "$chosen" ]; then
    "$SET_THEME" "$chosen"
fi
