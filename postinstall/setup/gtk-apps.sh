#!/bin/bash

sudo dnf install -y thunar thunar-archive-plugin thunar-volman file-roller lxappearance gtk-murrine-engine

if ls ~/.local/share/themes ~/.themes /usr/share/themes 2>/dev/null | grep -qi "Flat-Remix"; then
    echo "El Tema Flat-Remix-GTK-Grey para GTK y sus iconos ya se encuentra instalado"
else
    echo "Instalando el Tema Flat-Remix-GTK-Grey para GTK y sus iconos..."
    cd "$HOME/Escritorio/1.Projectos/repos"

    # Instalando tema gtk
    git clone https://github.com/daniruiz/flat-remix-gtk.git
    mkdir -p "$HOME/.themes"
    cp -r "$HOME/Escritorio/1.Projectos/repos/flat-remix-gtk/themes/Flat-Remix-GTK-Grey-Darkest-Solid" "$HOME/.themes/"
    mkdir -p "$HOME/.config/gtk-4.0/"
    cp -r flat-remix-gtk/themes/Flat-Remix-GTK-Grey-Darkest-Solid/gtk.4.0/* "$HOME/.config/gtk-4.0/"
    gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Grey-Darkest-Solid"

    # Instalando iconos del tema
    git clone https://github.com/daniruiz/flat-remix.git
    mkdir -p "$HOME/.local/share/icons"
    cp -r Flat-Remix/Flat-Remix-Grey-Dark "$HOME/.local/share/icons"
    gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Grey-Dark"

        # Eliminando Carpeta
    cd "$HOME/Escritorio/1.Projectos/repos"
    rm -rf flat-remix-gtk
    rm -rf Flat-Remix
    echo "El tema Flat-Remix-GTk-Grey para GTK y sus iconos han sido instalados"
fi

