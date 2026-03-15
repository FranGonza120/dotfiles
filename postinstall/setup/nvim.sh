#!/bin/bash

if command -v nvim >/dev/null 2>&1; then
    echo "nvim ya se encuentra instalado"
else
    echo "Instalando nvim"
    sudo dnf install -y nvim
fi

echo "Creando link para carpeta de configuracion de nvim"
ln -snf "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

echo "nvim configurado correctamente"


