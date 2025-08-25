#!/bin/bash

# Importar variables de color
source ~/Escritorio/3.Recursos/dotfiles/Temas/$1/colors.sh

# Crear archivo que sway puede incluir
touch ~/.config/sway/theme.conf

cat > ~/.config/sway/theme.conf <<EOF
# Colores para bordes de ventanas
client.focused          $active_border $active_border $background $active_border
client.unfocused        $inactive_border $inactive_border $background $inactive_border
client.focused_inactive $inactive_border $inactive_border $background $inactive_border
client.urgent           $urgent_border $urgent_border $background $urgent_border
EOF

