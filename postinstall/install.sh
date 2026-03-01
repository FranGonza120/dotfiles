#!/bin/bash
# Este archivo esta pensado para ser copiado en ~/ y ejecutarse para realizar el postinstall de la manera más liviana posible

set -euo pipefail

PARTICION_DIR=$HOME/Escritorio/3.Recursos
DOTFILES_DIR=$HOME/Escritorio/3.Recursos/dotfiles
POSTINSTALL_DIR=$DOTFILES_DIR/postinstall
CONFIG_DIR=$HOME/.config

SCRIPTS=()

for file in "$POSTINSTALL_DIR"/setup/*.sh; do
    filename=$(basename "$file" .sh)
    SCRIPTS+=("$filename")
done

function scripts_a_ejecutar() {

	INSTALACION_DEFAULT=(
		bash
		hyprland
		flatpaks
		gtk-apps
		nvim
		wofi
		zathura
		syncthing
		nextdns
		font
		starship
		bleachbit
		keyboard-layout
		alacritty
	)

	if [[ $# -ge 1 ]]; then
		#pattern=$(IFS="|"; printf "%s" "${SCRIPTS[*]}")
		for arg in "$@"; do
		    valid=false

		    for script in "${SCRIPTS[@]}"; do
			if [[ "$arg" == "$script" ]]; then
			    valid=true
			    break
			fi
		    done

		    if ! $valid; then
			echo "La opción --> $arg <-- no existe dentro de los scripts válidos"
			exit 1
		    fi
		done
		SCRIPTS_SELECCIONADOS=("$@")
	else
		SCRIPTS_SELECCIONADOS=("${INSTALACION_DEFAULT[@]}")
	fi
}

function instalacion() {
	# Exportando variables para los scripts hijos
	export DOTFILES_DIR CONFIG_DIR PARTICION_DIR POSTINSTALL_DIR
	for arg in "$@"; do
		echo "$arg"
		bash "$POSTINSTALL_DIR/setup/$arg.sh"
	done
}

#opción help
if [[ ${1:-} == "--help" ]]; then
    echo "Uso: ./postinstall.sh [opciones]"
    echo "Opciones disponibles:"
    echo "${SCRIPTS[@]}"
    exit 0
fi

sudo dnf -y update
sudo dnf -y makecache

# Verificación de partición

echo "Verificando que la partición Personal se encuentra montada correctamente"
if [[ -d "$PARTICION_DIR" ]] && mountpoint -q "$HOME/Escritorio"; then
	echo "✔ La partición Personal está montada correctamente"
else
	echo "La partición no se encuentra montada"
	echo "Limpiando carpeta Escritorio"
	mkdir -p "$HOME/Escritorio"
	rm -rf $HOME/Escritorio/*

	UUID=$(sudo blkid -s UUID -o value  "/dev/disk/by-label/Personal" || true)

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

# Verificación y setup de git

if command -v git >/dev/null 2>&1; then
	echo "git se encuentra instalado"
else
	sudo dnf install -y git
	git config --global user.email "franco20047@gmail.com"
	git config --global user.name "FranGonza120"
fi

if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then 
	echo "La clave SSH está instalada"
else 
	echo "A presione enter en las opciones provistas por el generador de la clave ssh"
	ssh-keygen -t ed25519 -C "franco20047@gmail.com"
	eval "$(ssh-agent -s)"
	ssh-add "$HOME/.ssh/id_ed25519"
	echo "Agregue una nueva clave SSH en github y copie la siguiente clave:"
	cat "$HOME/.ssh/id_ed25519.pub"
	read -rp "Cuando agregue la clave y copie el contendido presione Enter." _
	#Confirmación de conexióna github
	echo "Confirmando la ssh-key con github.com"
	echo "si pregunta sobre establecer conexion pone yes"
	if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	    echo "✔ SSH con GitHub funcionando (key OK)"
	else
	    echo "❌ No se pudo autenticar con GitHub vía SSH"
	fi
	echo "Vaya a tty3 y ejecute nuevamente el script para evitar problemas de compatibilidad"
	exit 0
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


INSTALACION_DEFAULT=(
	hyprland
	flatpaks
	gtk-apps
	nvim
	wofi
	zathura
	syncthing
	nextdns
	font
	starship
	bleachbit
	keyboard-layout
	alacritty
)

SCRIPTS_SELECIONADOS=()

scripts_a_ejecutar "$@"
echo "${SCRIPTS_SELECCIONADOS[@]}"
instalacion "${SCRIPTS_SELECCIONADOS[@]}"

echo "El postinstall ha terminado"

