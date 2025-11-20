#!/bin/bash

# Verificar particion montada
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
