# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
export XCURSOR_THEME=Capitaine-cursors
export XCURSOR_SIZE=24
export GTK_THEME=Flat-Remix-GTK-Grey-Darkest-Solid
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc


eval "$(starship init bash)"
alias neofetch='neofetch --source ~/.config/neofetch/edoBuilding.txt'
alias fastfetch='fastfetch -c /home/frangonza120/.config/fastfetch/config.jsonc --logo ~/.config/fastfetch/edoBuilding.txt'
alias screenshot='grim -g "$(slurp)" - | wl-copy'
alias apagar='sudo shutdown now'
alias nvimnotes='cd ~/Escritorio/2.Areas/SegundoCerebro && nvim $(date '+%Y-%m-%d_%H-%M-%S').md'
alias dnfupdate='sudo dnf -q list updates && sudo dnf -q update'
alias bleachbit='sudo bleachbit'
alias limpiardocker='docker system prune -a --volumes -f'
alias desconectar-disco='function _desconectar_disco(){ \
  if [ -z "$1" ]; then echo "⚠️  Usá: desconectar-disco /dev/sdX"; return 1; fi; \
  for part in $(lsblk -ln $1 | awk "{print \"/dev/\"\$1}"); do \
    echo "Desmontando $part..."; \
    sudo umount "$part" 2>/dev/null || echo "  ⚠️  No se pudo desmontar $part"; \
  done; \
  echo "Sincronizando..."; \
  sync; \
  echo "Apagando disco $1..."; \
  sudo udisksctl power-off -b $1 && echo "✅ Disco apagado con seguridad."; \
}; _desconectar_disco'
