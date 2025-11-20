#!/bin/bash

sudo dnf install -C -y thunar thunar-archive-plugin thunar-volman file-roller lxappearance gtk-murrine-engine

#Instalar tema TokyoNight
# Repositorio para clonar https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git 
#  Instalar tema de iconos
#  Instalar tema de gtk
if ls ~/.local/share/themes ~/.themes /usr/share/themes 2>/dev/null | grep -qi "tokyo"; then
    echo "El Tema ya se encuentra instalado"
else
    cd "$HOME/Escritorio/1.Projectos/repos"
    git clone https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git
    cd Tokyonight-GTK-Theme/themes
    sudo chmod +x install.sh
    mkdir -p "$HOME/.themes"
    ./install.sh -c dark -l 
    cd "$HOME/Escritorio/1.Projectos/repos"
    rm -rf Tokyonight-GTK-Theme
fi

if ls "$HOME/.local/share/icons" "$HOME/.icons" /usr/share/icons 2>/dev/null | grep -qi "tokyo"; then
    echo "Los iconos se encuentra instalados"
else
    echo "Cómo lo instalo"
fi

echo "averiguar si se instaló los iconos del tema!!!"
echo "Terminar este script!!"

# deberían en estar en las carpetas o ~/.local/share/icons o ~/.icons
# En caso de que no estén, la carpeta de estos está en Tokyonight-GTK-Theme/icons
# usar TokyoNightDark
