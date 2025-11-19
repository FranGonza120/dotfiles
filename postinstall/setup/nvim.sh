#!/bin/bash

echo "Instalando nvim"
sudo dnf install -C -y nvim

echo "Copiando dotfiles de nvim"
cp -r "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

echo "nvim configurado correctamente"


