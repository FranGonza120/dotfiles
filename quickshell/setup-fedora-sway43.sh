#!/usr/bin/env bash
set -u

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "%b\n" "${BLUE}$*${NC}"; }
ok() { printf "%b\n" "${GREEN}$*${NC}"; }
warn() { printf "%b\n" "${YELLOW}$*${NC}"; }
err() { printf "%b\n" "${RED}$*${NC}"; }

if ! command -v dnf >/dev/null 2>&1; then
    err "This setup is for Fedora and needs dnf."
    exit 1
fi

if [ -r /etc/fedora-release ] && ! grep -q " 43" /etc/fedora-release; then
    warn "This script targets Fedora 43. Detected: $(cat /etc/fedora-release)"
fi

DNF=(sudo dnf install -y)

CORE_PACKAGES=(
    qt6-qtbase
    qt6-qtdeclarative
    qt6-qtsvg
    qt6-qtwayland
    sway
    pipewire
    wireplumber
    NetworkManager
    bluez
    upower
    power-profiles-daemon
    grim
    slurp
    brightnessctl
    playerctl
    wl-clipboard
    wf-recorder
    libnotify
    xdg-utils
    procps-ng
    util-linux
    foot
)

OPTIONAL_PACKAGES=(
    python3-pywal
    blueman
    nm-connection-editor
    wlogout
    google-inter-fonts
    google-material-design-icons-fonts
)

install_group() {
    local name="$1"
    shift

    log "Installing $name packages..."
    if "${DNF[@]}" "$@"; then
        ok "Installed $name packages."
        return 0
    fi

    warn "Batch install failed. Retrying package by package."
    local pkg
    for pkg in "$@"; do
        if rpm -q "$pkg" >/dev/null 2>&1; then
            ok "$pkg already installed."
        elif "${DNF[@]}" "$pkg"; then
            ok "Installed $pkg."
        else
            warn "Skipped $pkg. It may not exist in your enabled Fedora repos."
        fi
    done
}

install_group core "${CORE_PACKAGES[@]}"
install_group optional "${OPTIONAL_PACKAGES[@]}"

log "Enabling useful system services..."
for service in NetworkManager bluetooth power-profiles-daemon; do
    if systemctl list-unit-files "${service}.service" >/dev/null 2>&1; then
        sudo systemctl enable --now "${service}.service" || warn "Could not enable ${service}.service"
    fi
done

chmod +x "$SCRIPT_DIR/reload-quickshell.sh" 2>/dev/null || true

if ! command -v quickshell >/dev/null 2>&1; then
    warn "quickshell was not found."
    warn "Install it from a Fedora/COPR source you trust, then run: quickshell"
fi

if command -v wal >/dev/null 2>&1; then
    if [ -f "$HOME/.cache/wal/colors.json" ]; then
        ok "Pywal colors found."
    else
        warn "Run: wal -i /path/to/wallpaper"
    fi
else
    warn "wal was not found. Install pywal manually if python3-pywal was unavailable."
fi

cat <<'EOF'

Fedora Sway notes:
- To autostart, add this to ~/.config/sway/config:
    exec quickshell

Done.
EOF
