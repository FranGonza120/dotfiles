#!/bin/bash

if command -v syncthing >/dev/null 2>&1; then
    echo "syncthing ya se encuentra instalado"
else
    sudo dnf install -y syncthing
    echo "Syncthing instalado"
fi
echo "Se considera que se inicia syncthing desde hyprland"

