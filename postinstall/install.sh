#!/bin/bash
# Este archivo esta pensado para ser copiado en ~/ y ejecutarse para realizar el postinstall de la manera más liviana posible

set -euo pipefail

#opción help
if [[ ${1:-} == "--help" ]]; then
    echo "Uso: ./postinstall.sh [opciones]"
    echo "Opciones disponibles:"
    echo "  hyprland  flatpaks  gtk-apps  nvim  wezterm  wofi  zathura  syncthing  nextdns  font  starship bleachbit"
    exit 0
fi

PARTICION_DIR=$HOME/Escritorio/3.Recursos
DOTFILES_DIR=$HOME/Escritorio/3.Recursos/dotfiles
POSTINSTALL_DIR=$DOTFILES_DIR/postinstall
CONFIG_DIR=$HOME/.config

# Verificar particion montada
echo "Verificando que la partición Personal se encuentra montada correctamente"
if [[ -d "$PARTICION_DIR" ]] && mountpoint -q "$HOME/Escritorio"; then
	echo "✔ La partición Personal está montada correctamente"
else
	echo "La partición no se encuentra montada"
	echo "Limpiando carpeta Escritorio"
	mkdir -p "$HOME/Escritorio"
	rm -rf $HOME/Escritorio/*

	UUID=$(blkid -s UUID -o value  "/dev/disk/by-label/Personal" || true)

	# Verificación de que la partición se encuentra en el sistema
	if [[ -z "$UUID" ]]; then
		echo "No se encuentra la partición Personal en el sistema"
		exit 1
	fi
	if ! grep -q "$UUID" /etc/fstab; then
		MOUNTPOINT="$HOME/Escritorio"
		echo "UUID=$UUID $MOUNTPOINT ext4 defaults 0 2" | sudo tee -a /etc/fstab > /dev/null
	fi
	sudo mount -U "$UUID" "$HOME/Escritorio"
	echo "Se ha montado la partición Personal a la carpeta ~/Escritorio exitosamente"
fi

# Verificar dotfiles disponibles
echo "Verificando que los dotfiles están disponibles"
if [[ -d "$DOTFILES_DIR" ]]; then
	echo "El repositorio se encuentra en la posición adecuada"
	echo "Actualizando contenido del repositorio"
	cd "$DOTFILES_DIR"
	git fetch
	if ! git diff --quiet; then
	    echo "⚠️ Cambios locales detectados en dotfiles. No se puede hacer pull."
	else
	    git pull --ff-only
	fi
else
	echo "El repositorio no se encuentra en la posición adecuada"
	echo "Clonando repositorio dotfiles"
	cd "$PARTICION_DIR"
	git clone https://github.com/frangonza120/dotfiles
	cd dotfiles
fi
# Activar scripts ejecutables
echo "Activando scripts ejecutables de dotfiles"
find "$DOTFILES_DIR" -name "*.sh" -exec chmod +x {} \;

sudo dnf -y makecache

# verificar montado de partición Personal
if [[ $# -ge 1 ]]; then
	for arg in "$@"; do
		case $arg in
			hyprland|flatpaks|gtk-apps|nvim|wezterm|wofi|zathura|syncthing|nextdns|font|starship|bleachbit)
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

