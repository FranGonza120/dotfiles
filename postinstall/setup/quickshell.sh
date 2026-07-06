#!/bin/bash

if command -v qs >/dev/null 2>&1; then
	sudo dnf copr enable errornointernet/quickshell
	sudo dnf install quickshell
fi

ln -snf "$DOTFILES_DIR/quickshell" "$CONFIG_DIR/quickshell" 
