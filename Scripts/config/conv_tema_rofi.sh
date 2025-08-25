#!/bin/bash

source ~/Escritorio/3.Recursos/dotfiles/Temas/$1/colors.sh

cat > ~/.config/rofi/colors.rasi <<EOF
* {
  background: $background;
  background-alt: $backgroundalt;
  foreground: $foreground;
  selected: $accent;
  urgent: $urgent;
  border: $border;
}
EOF

