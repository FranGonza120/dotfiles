#!/bin/bash

# Gamma para blanco y negro (luminancia perceptual)
BWN_GAMMA="0.2126:0.7152:0.0722"
COLOR_GAMMA="1:1:1"

# Verificar la gamma actual de la primera pantalla como referencia
FIRST_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name' | head -n1)
CURRENT_GAMMA=$(wlr-randr --json | jq -r --arg name "$FIRST_OUTPUT" '.outputs[] | select(.name == $name) | .gamma | join(":")')

# Determinar si se activa o desactiva escala de grises
if [[ "$CURRENT_GAMMA" == "$COLOR_GAMMA" ]]; then
    NEW_GAMMA="$BWN_GAMMA"
else
    NEW_GAMMA="$COLOR_GAMMA"
fi

# Aplicar a todas las salidas activas
for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name'); do
    wlr-randr --output "$output" --gamma "$NEW_GAMMA"
done

