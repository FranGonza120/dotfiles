#!/bin/bash

if command -v nvim >/dev/null 2>&1; then
    echo "nvim ya se encuentra instalado"
else
    echo "Instalando nvim"
    sudo dnf install -y nvim
fi

echo "Copiando dotfiles de nvim"
cp -r "$DOTFILES_DIR/nvim" "$CONFIG_DIR/"

echo "nvim configurado correctamente"


