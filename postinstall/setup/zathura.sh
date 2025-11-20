#!/bin/bash


if command -v zathura >/dev/null 2>&1; then
    echo "zathura ya se encuentra instalado"
else
    sudo dnf install -y zathura zathura-pdf-poppler
    echo "zathura instalado correctamente para leer pdfs"
fi
