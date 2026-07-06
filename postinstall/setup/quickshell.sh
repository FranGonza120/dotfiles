#!/bin/bash
set -euo pipefail

PACKAGES=(
    playerctl
    google-material-design-icons-fonts
    pipewire
    wireplumber
    NetworkManager
    nm-connection-editor
    bluez
    blueman
    upower
    brightnessctl
    fd-find
    foot
    swaybg
    xdg-utils
    procps-ng
)

if ! command -v quickshell >/dev/null 2>&1; then
    echo "Habilitando COPR e instalando quickshell"
    sudo dnf -y copr enable errornointernet/quickshell
    sudo dnf install -y quickshell
    sudo pip3 install pywal
else
    echo "quickshell ya se encuentra instalado"
fi

echo "Instalando dependencias minimas para quickshell"
sudo dnf install -y "${PACKAGES[@]}"

echo "Creando link de configuracion de quickshell"
ln -snf "$DOTFILES_DIR/quickshell" "$CONFIG_DIR/quickshell"

chmod +x "$DOTFILES_DIR/quickshell/reload-quickshell.sh" 2>/dev/null || true
