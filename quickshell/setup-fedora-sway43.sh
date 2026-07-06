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
    swaybg
    swayidle
    swaylock
    pipewire
    wireplumber
    NetworkManager
    NetworkManager-applet
    bluez
    upower
    grim
    slurp
    brightnessctl
    playerctl
    wl-clipboard
    fd-find
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    procps-ng
    util-linux
    alacritty
    foot
    python3-pywal
    blueman
    google-material-design-icons-fonts
)

OPTIONAL_PACKAGES=(
    nm-connection-editor
    capitaine-cursors-theme
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

install_first_available() {
    local label="$1"
    shift

    local pkg
    for pkg in "$@"; do
        if rpm -q "$pkg" >/dev/null 2>&1; then
            ok "$label already installed via $pkg."
            return 0
        fi

        if dnf info "$pkg" >/dev/null 2>&1 && "${DNF[@]}" "$pkg"; then
            ok "Installed $label via $pkg."
            return 0
        fi
    done

    warn "Could not install $label automatically."
    return 1
}

install_first_available "JetBrains Mono Nerd Font" \
    jetbrains-mono-nerd-fonts \
    nerd-fonts-jetbrains-mono \
    jetbrainsmono-nerd-fonts

log "Enabling useful system services..."
for service in NetworkManager bluetooth; do
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

if command -v fc-match >/dev/null 2>&1; then
    if fc-match "JetBrainsMono Nerd Font" | grep -qi "JetBrains"; then
        ok "JetBrains Mono Nerd Font found."
    else
        warn "JetBrains Mono Nerd Font not found. Install it manually if the auto step above failed."
    fi
fi

cat <<'EOF'

Fedora Sway notes:
- This repo currently expects:
  - JetBrains Mono Nerd Font
  - Material Design Icons
  - nm-applet and blueman-applet
  - swaybg, swayidle, swaylock, fd, playerctl
- QuickShell itself is not installed by this script.

Done.
EOF
