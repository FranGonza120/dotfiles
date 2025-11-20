#!/bin/bash
# Este archivo esta pensado para ser copiado en ~/ y ejecutarse para realizar el postinstall de la manera más liviana posible

set -euo pipefail

#opción help
if [[ ${1:-} == "--help" ]]; then
    echo "Uso: ./postinstall.sh [opciones]"
    echo "Opciones disponibles:"
    echo "  hyprland  flatpaks  gtk-apps  nvim  wezterm  wofi  zathura  syncthing  nextdns  font  starship  bleachbit  bash  keyboard-layout"
    exit 0
fi

PARTICION_DIR=$HOME/Escritorio/3.Recursos
DOTFILES_DIR=$HOME/Escritorio/3.Recursos/dotfiles
POSTINSTALL_DIR=$DOTFILES_DIR/postinstall
CONFIG_DIR=$HOME/.config

sudo dnf -y update
sudo dnf -y makecache

./before/setup-particion.sh
./before/setup-git.sh


# verificar montado de partición Personal
if [[ $# -ge 1 ]]; then
	for arg in "$@"; do
		case $arg in
			hyprland|flatpaks|gtk-apps|nvim|wezterm|wofi|zathura|syncthing|nextdns|font|starship|bleachbit|bash|keyboard-layout)
				bash "$POSTINSTALL_DIR/setup/$arg.sh"
				;;
			*)
				echo "❌ Opción desconocida: $arg"
				exit 1 ;;
		esac
	done
else
	echo "Ejecutando todos los scripts disponibles"
	find "$POSTINSTALL_DIR/setup" -name "*.sh" -exec bash {} \;
fi

echo "El postinstall ha terminado"

