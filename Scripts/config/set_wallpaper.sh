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

if command -v wal >/dev/null 2>&1; then
  wal -nstqi "$WALLPAPER"
fi

# Recargar sway
killall swaybg 2>/dev/null || true
swaymsg reload >/dev/null
echo "✅ Wallpaper actualizado: $WALLPAPER"
