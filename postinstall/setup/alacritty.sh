#!/bin/bash

sudo dnf -y install alacritty tmux fzf

ln -snf "$DOTFILES_DIR/alacritty" "$CONFIG_DIR/alacritty"
ln -snf "$DOTFILES_DIR/tmux" "$CONFIG_DIR/tmux"
ln -snf "$DOTFILES_DIR/starship" "$CONFIG_DIR/starship"
