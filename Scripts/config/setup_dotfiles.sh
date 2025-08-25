#!/bin/bash

DOTFILES="$HOME/Escritorio/3.Recursos/dotfiles"
DEST_DIR="$HOME/.config"

echo "🔧 Copiando configuraciones desde $DOTFILES a $DEST_DIR..."

for dir in "$DOTFILES"/*; do
    name=$(basename "$dir")
    if [ "$name" != "Temas" ]; then
        echo "→ Instalando $name..."
        mkdir -p "$DEST_DIR/$name"
        cp -r "$dir"/* "$DEST_DIR/$name/"
    else
        echo "⏭️  Ignorando carpeta de temas ($name)"
    fi
done

echo "✅ Configuraciones instaladas correctamente."
