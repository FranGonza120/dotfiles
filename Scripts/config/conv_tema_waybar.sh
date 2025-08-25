#!/bin/bash

source ~/Escritorio/3.Recursos/dotfiles/Temas/$1/colors_waybar.sh

cat > ~/.config/waybar/colors.css <<EOF
/* General styling */
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMonoNerdFont-Regular", monospace;
    font-size: 15px;
    box-shadow: none;
    text-shadow: none;
    transition-duration: 0s;
}

window {
    color: ${text}; /* Texto principal */
    background: ${background_transparent}; /* Fondo transparente */
}

window#waybar.solo {
    color: ${text};
    background: ${background_opaque}; /* Fondo con opacidad */
}

/* Workspaces styling */
#workspaces {
    margin: 0 5px;
}

#workspaces button {
    padding: 0 5px;
    color: ${inactive_text}; /* Color desactivado */
    background-color: transparent;
}

#workspaces button.visible {
    color: ${visible_text}; /* Color visible */
}

#workspaces button.focused {
    border-top: 3px solid ${focus_border}; /* Borde para foco */
    border-bottom: 3px solid ${transparent};
}

#workspaces button.urgent {
    color: ${urgent}; /* Color urgencia */
}

/* Module spacing */
#mode, #battery, #cpu, #memory, #network, #pulseaudio, #idle_inhibitor, #custom-storage, #custom-spotify {
    margin: 0px 6px 0px 10px;
    min-width: 25px;
}

#clock {
    margin: 0px 16px 0px 10px;
    min-width: 140px;
}

/* Battery specific styling */
#battery.warning {
    color: ${warning}; /* Amarillo para advertencias */
}

#battery.critical {
    color: ${urgent}; /* Rojo crítico */
}

#battery.charging {
    color: ${focus_border}; /* Azul para carga */
}

/* Storage styling */
#custom-storage.warning {
    color: ${warning};
}

#custom-storage.critical {
    color: ${urgent};
}

/* Clock styling */
#clock {
    color: ${visible_text};
}

/* Optional: Custom Spotify styling */
#custom-spotify {
    color: ${visible_text};
}
EOF
