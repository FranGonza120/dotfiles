#!/bin/bash

WALLPAPER="$1"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Validación
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
  echo "❌ Fondo no válido: $WALLPAPER"
  exit 1
fi

# Asegurar que el archivo exista
touch "$CONFIG_FILE"

# Reemplazar  contenido del archivo
echo "preload = $WALLPAPER" > "$CONFIG_FILE"
echo "wallpaper = , $WALLPAPER" >> "$CONFIG_FILE"

# Recargar sway
hyprctl hyprpaper reload ,$WALLPAPER
hyprctl hyprpaper preload $WALLPAPER
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
hyprctl hyprpaper wallpaper "HDMI-A-1,$WALLPAPER"
echo "✅ Wallpaper actualizado: $WALLPAPER"
