#!/bin/bash

# Detectar si el monitor externo está conectado
if swaymsg -t get_outputs | grep -q "HDMI-A-1"; then
    swaymsg output HDMI-A-1 enable resolution 1920x1080 position 0 0
    swaymsg output eDP-1 enable resolution 1920x1080 position 1920 0
else
    swaymsg output HDMI-A-1 disable
    swaymsg output eDP-1 enable position 0 0
fi

