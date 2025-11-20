#!/bin/bash


if command -v git >/dev/null 2>&1; then
	echo "git se encuentra instalado"
else
	sudo dnf install -y git
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
	echo "Se instaló la clave SSH"
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

