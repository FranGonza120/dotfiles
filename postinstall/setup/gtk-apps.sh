#!/bin/bash

sudo dnf install -y thunar thunar-archive-plugin thunar-volman file-roller lxappearance gtk-murrine-engine

#Instalar tema TokyoNight
# Repositorio para clonar https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git 
#  Instalar tema de iconos
#  Instalar tema de gtk
if ls ~/.local/share/themes ~/.themes /usr/share/themes 2>/dev/null | grep -qi "tokyo"; then
    echo "El Tema TokyoNight para GTK y sus iconos ya se encuentra instalado"
else
    sudo dnf install gtk-murrine-engine
    cd "$HOME/Escritorio/1.Projectos/repos"
    git clone https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git
    cd Tokyonight-GTK-Theme/themes
    sudo chmod +x install.sh
    mkdir -p "$HOME/.themes"
    ./install.sh -c dark -l 

    # Instalando paquetes de iconos tanto del tema de gtk como otro paquete de tema TokyoNight
    sudo mv ./icons/Tokyonight-Dark/ "$HOME/.local/share/icons/"
    sudo cp -r "$DOTFILES_DIR/icons/TokyoNight-SE" "$HOME/.local/share/icons/"

    # Colocando tema en GTk-3.0
    mkdir -p ~/.config/gtk-3.0

    cat > ~/.config/gtk-3.0/settings.ini <<EOF
    [Settings]
    gtk-theme-name=Tokyonight-Dark
    gtk-icon-theme-name=TokyoNight-SE
    gtk-font-name=JetBrainsMono Nerd Font Mono 10
    EOF

    # Eliminando Carpeta
    cd "$HOME/Escritorio/1.Projectos/repos"
    rm -rf Tokyonight-GTK-Theme
    echo "El tema TokyoNight para GTK y sus iconos han sido instalados"
fi

