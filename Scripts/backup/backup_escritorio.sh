#!/bin/bash

# Configuración
PARTICION="/dev/disk/by-label/BACKUP"
PUNTO_MONTAJE="/mnt/backup"
ORIGEN="/home/frangonza120/Escritorio/"
DESTINO="$PUNTO_MONTAJE/EscritorioBackup"

# Se crea el punto de montaje si no existe
sudo mkdir -p "$PUNTO_MONTAJE"
# Montar si no está montado
if ! mountpoint -q "$PUNTO_MONTAJE"; then
    echo "📦 Montando $PARTICION en $PUNTO_MONTAJE..."
    sudo mount "$PARTICION" "$PUNTO_MONTAJE" || { echo "❌ Error al montar"; exit 1; }
else
    echo "✅ Ya montado: $PUNTO_MONTAJE"
fi

# Crear destino si no existe
sudo mkdir -p "$DESTINO"

# Ejecutar backup con rsync
echo "🔄 Iniciando backup de $ORIGEN a $DESTINO..."
sudo rsync -av --delete-excluded --delete --exclude-from="$HOME/Escritorio/3.Recursos/dotfiles/Scripts/backup/.rsync_excludes" "$ORIGEN" "$DESTINO"

echo "✅ Backup completado."

# Opcional: desmontar automáticamente
 echo "⏏️ Desmontando..."
 sudo umount "$PUNTO_MONTAJE"

