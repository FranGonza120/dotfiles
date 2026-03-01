#!/bin/bash
set -euo pipefail

# =======================
#   CONFIGURACIÓN
# =======================
REPO_URL="https://github.com/wezterm/wezterm.git"
REPO_DIR="$HOME/wezterm"
ICON_SRC="$REPO_DIR/assets/icon/terminal.png"
ICON_DEST="$HOME/.local/share/icons/wezterm.png"
DESKTOP_FILE="$HOME/.local/share/applications/wezterm.desktop"
if command -v wezterm >/dev/null 2>&1; then
    echo "wezterm ya se encuentra instalado"
else
    # =======================
    #   INSTALAR RUSTUP
    # =======================
    echo "⏳ Instalando Rust (si es necesario)..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"

    # =======================
    #   CLONAR WERZTERM
    # =======================
    echo "📦 Clonando repositorio WezTerm..."
    git clone --depth=1 --branch=main --recursive "$REPO_URL" "$REPO_DIR"

    cd "$REPO_DIR"
    git submodule update --init --recursive

    # =======================
    #   DEPENDENCIAS DE WEZTERM
    # =======================
    echo "🔧 Instalando dependencias..."
    ./get-deps

    # =======================
    #   COMPILAR WEZTERM
    # =======================
    echo "⚙️ Compilando WezTerm (esto tomará un rato)..."
    cargo build --release

    # =======================
    #   COPIAR BINARIOS AL SISTEMA
    # =======================
    echo "📁 Instalando binarios en /usr/local/bin..."

    sudo install -m 755 target/release/wezterm /usr/local/bin/
    sudo install -m 755 target/release/wezterm-gui /usr/local/bin/

    # =======================
    #   COPIAR ÍCONO
    # =======================
    echo "🖼️ Instalando ícono de WezTerm..."

    mkdir -p "$HOME/.local/share/icons"

    if [[ -f "$ICON_SRC" ]]; then
	cp "$ICON_SRC" "$ICON_DEST"
    else
	echo "⚠️ Advertencia: No se encontró $ICON_SRC. El .desktop funcionará igual."
    fi

    # =======================
    #   CREAR .DESKTOP
    # =======================
    echo "📄 Creando archivo .desktop..."

    mkdir -p "$(dirname "$DESKTOP_FILE")"

    cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=WezTerm
Comment=WezTerm Terminal Emulator
Exec=/usr/local/bin/wezterm
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/wezterm.png
Categories=System;TerminalEmulator;
EOF

    # Asegurar permisos
    chmod +x "$DESKTOP_FILE"

    # =======================
    #   LIMPIEZA FINAL
    # =======================
    echo "🧹 Eliminando repositorio para limpiar espacio..."
    cd "$HOME"
    rm -rf "$REPO_DIR"
    echo "✨ WezTerm instalado correctamente desde source."
fi

echo "Copiendo configuración de wezterm"
ln -snf "$DOTFILES_DIR/wezterm" "$CONFIG_DIR/wezterm"

