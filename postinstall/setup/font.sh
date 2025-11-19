#!/bin/bash
set -euo pipefail

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
TMP_DIR="$(mktemp -d)"
FONT_DIR="$HOME/.local/share/fonts"
ZIP_PATH="$TMP_DIR/JetBrainsMono.zip"

echo "📥 Descargando JetBrainsMono Nerd Font..."
mkdir -p "$TMP_DIR"

# Descargar con curl o wget según lo que haya
if command -v curl >/dev/null 2>&1; then
    curl -fL "$FONT_URL" -o "$ZIP_PATH"
elif command -v wget >/dev/null 2>&1; then
    wget -O "$ZIP_PATH" "$FONT_URL"
else
    echo "❌ No se encontró ni curl ni wget. Instalá uno de los dos y volvé a ejecutar."
    exit 1
fi

echo "📂 Creando directorio de fuentes en $FONT_DIR ..."
mkdir -p "$FONT_DIR"

# Asegurar que unzip esté disponible
if ! command -v unzip >/dev/null 2>&1; then
    echo "⚠️ 'unzip' no está instalado. Intentando instalarlo..."
        sudo dnf install -y unzip
fi

echo "📦 Descomprimiendo fuentes en $FONT_DIR ..."
unzip -o "$ZIP_PATH" -d "$FONT_DIR"

echo "🧹 Limpiando temporales..."
rm -rf "$TMP_DIR"

echo "✨ JetBrainsMono Nerd Font instalada en: $FONT_DIR"
