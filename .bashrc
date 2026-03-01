# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Habilitar comandos fzf
if command -v fzf >/dev/null; then
  source /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null || true
fi

# PATH
PATH="/opt/jdk-17.0.2/bin:$PATH"
# Flutter sdk
PATH="$HOME/Escritorio/3.Recursos/fluttersdk/flutter/bin:$PATH"
# Beancount environment
PATH="$HOME/Escritorio/2.Areas/Finanzas/beancount-venv/bin:$PATH"
export PATH

#Exports
export XCURSOR_THEME=Capitaine-cursors
export XCURSOR_SIZE=24
export GTK_THEME=Flat-Remix-GTK-Grey-Darkest-Solid
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --prompt='❯ '"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Evals
eval "$(fzf --bash)"
eval "$(starship init bash)"

# Aliases
alias neofetch='neofetch --source ~/.config/neofetch/edoBuilding.txt'
alias fastfetch='fastfetch -c /home/frangonza120/.config/fastfetch/config.jsonc --logo ~/.config/fastfetch/edoBuilding.txt'
alias screenshot='grim -g "$(slurp)" - | wl-copy'
alias apagar='sudo shutdown now'
alias nvimnotes='cd ~/Escritorio/2.Areas/SegundoCerebro && nvim $(date '+%Y-%m-%d_%H-%M-%S').md'
alias dnfupdate='sudo dnf -q list updates && sudo dnf -q update'
alias bleachbit='sudo bleachbit'
alias limpiardocker='docker system prune -a --volumes -f'

# Shortcuts
bind -x '"\C-f":tm_session_creator'
bind -x '"\C-h":tm_home_session'

# Functions
function desconectar_disco() {
  if [ -z "$1" ]; then echo "⚠️  Usá: desconectar-disco /dev/sdX"; return 1; fi;

  for part in $(lsblk -ln $1 | awk "{print \"/dev/\"\$1}"); do
    echo "Desmontando $part...";
    sudo umount "$part" 2>/dev/null || echo "  ⚠️  No se pudo desmontar $part"
    done
    echo "Sincronizando..."
    sync
    echo "Apagando disco $1..."
    sudo udisksctl power-off -b $1 && echo "✅ Disco apagado con seguridad."
}

function tm_session_creator() {
  dir=$(fd \
    --type d \
    --hidden \
    --exclude .git . ~/Escritorio ~/.config 2>/dev/null | fzf)

  [ -z "$dir" ] && return

  session=$(basename "$dir" | tr . _)

  if ! tmux has-session -t="$session" 2>/dev/null; then
    tmux new-session -ds "$session" -c "$dir"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}

function tm_home_session() {
  if ! tmux has-session -t="Home" 2>/dev/null; then
    tmux new-session -ds "Home" -c "$HOME"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "Home"
  else
    tmux attach -t "Home"
  fi
}


