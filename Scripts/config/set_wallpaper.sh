#!/bin/bash

WALLPAPER="$1"
CONFIG_FILE="$HOME/.config/sway/wallpaper.conf"

# Validación
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
  echo "❌ Fondo no válido: $WALLPAPER"
  exit 1
fi

# Asegurar que el archivo exista
touch "$CONFIG_FILE"

# Reemplazar  contenido del archivo
echo "exec_always swaybg -i \"$WALLPAPER\" -m fill"
echo "exec_always swaybg -i \"$WALLPAPER\" -m fill" > "$CONFIG_FILE"

# Recargar sway
killall swaybg
swaymsg reload
echo "✅ Wallpaper actualizado: $WALLPAPER"
