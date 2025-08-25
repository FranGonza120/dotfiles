#!/bin/bash

# Obtener el volumen actual
current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')

# Incrementar o decrementar el volumen según el argumento
if [[ $1 == "up" ]]; then
  if [[ $current_volume -lt 100 ]]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
  else
    echo "El volumen ya está al máximo permitido (100%)"
  fi
elif [[ $1 == "down" ]]; then
  if [[ $current_volume -gt 0 ]]; then
    pactl set-sink-volume @DEFAULT_SINK@ -5%
  else
    echo "El volumen ya está al mínimo permitido (0%)"
  fi
elif [[ $1 == "mute" ]]; then
  pactl set-sink-mute @DEFAULT_SINK@ toggle
fi

