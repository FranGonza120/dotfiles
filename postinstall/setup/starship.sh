!#/bin/bash

echo "Starship instalado exitosamente"

if command -v starship >/dev/null 2>&1; then
    echo "✔ starship ya está instalado, salto instalación"
else
    echo "⬇ Instalando starship..."
    curl -sS https://starship.rs/install.sh | sh
fi
