#!/bin/bash

# Definir las pantallas
LAPTOP="eDP-1"      # Nombre de la pantalla de la laptop
MONITOR="HDMI-A-1"  # Nombre del monitor externo (ajústalo con swaymsg -t get_outputs)

# Detectar si el monitor externo está conectado
if swaymsg -t get_outputs | grep -q "$MONITOR.*enabled"; then
    # Si el monitor está conectado, ejecutar Waybar en el monitor externo
    waybar -o $MONITOR &
else
    # Si el monitor NO está conectado, ejecutar Waybar en la pantalla de la laptop
    waybar -o $LAPTOP &
fi

