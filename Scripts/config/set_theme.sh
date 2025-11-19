#!/bin/bash

# Validar argumento
THEME_NAME="$1"
THEME_DIR="$HOME/Escritorio/3.Recursos/dotfiles/temas/$THEME_NAME"

if [ -z "$THEME_NAME" ]; then
  echo "❌ Usá: $0 <nombre_del_tema>"
  exit 1
fi

if [ ! -f "$THEME_DIR/colors.sh" ]; then
  echo "❌ No se encontró el tema en: $THEME_DIR/colors.sh"
  exit 1
fi

# Ejecutar scripts de conversión
echo "🎛️ Generando configuración para sway..."
bash "$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/conv_tema_sway.sh $1"

echo "🎛️ Generando configuración para rofi..."
bash "$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/conv_tema_rofi.sh $1"

echo "🎛️ Generando configuración para waybar..."
bash "$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/conv_tema_waybar.sh $1"

#Cambiar tema para nvim y wezterm
bash "$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/conv_tema_nvim.sh $1"
bash "$HOME/Escritorio/3.Recursos/dotfiles/Scripts/config/conv_tema_wezterm.sh $1"

swaymsg reload
echo "✅ Tema '$THEME_NAME' aplicado. Recargá sway si es necesario con: swaymsg reload"
