#!/bin/bash

sudo dnf -y install alacritty tmux fzf

echo "Creando links para carpetas de configuración de alacritty, tmux y starship"
ln -snf "$DOTFILES_DIR/alacritty" "$CONFIG_DIR/alacritty"
ln -snf "$DOTFILES_DIR/tmux" "$CONFIG_DIR/tmux"
ln -snf "$DOTFILES_DIR/starship" "$CONFIG_DIR/starship"
