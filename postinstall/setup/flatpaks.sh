#!/bin/bash
set -euo pipefail

# ==============================
#   CONFIGURACIÓN DE FLATHUB
# ==============================

echo "🔍 Verificando si Flathub está habilitado..."

if flatpak remote-list | grep -q "flathub"; then
    echo "✔ Flathub ya está configurado."
else
    echo "➕ Agregando Flathub..."
    sudo flatpak remote-add --if-not-exists \
        flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "✔ Flathub agregado correctamente."
fi


FLATPAKS=(
	org.keepassxc.KeePassXC
	dev.vencord.Vesktop
	com.github.neithern.g4music
	md.obsidian.Obsidian
	app.zen_browser.zen
)

echo "📦 Instalando Flatpaks..."

for pkg in "${FLATPAKS[@]}"; do
    if flatpak list | grep -q "$pkg"; then
        echo "✔ $pkg ya está instalado."
    else
        echo "⬇ Instalando $pkg ..."
        flatpak install -y flathub "$pkg"
    fi
done

echo "✨ Todos los Flatpaks instalados correctamente."
