#!/bin/bash


if command -v bleachbit >/dev/null 2>&1; then
    echo "Bleachbit ya se encuentra instalado"
else
    sudo dnf install -y bleachbit
    echo "Bleachbit instalado correctamente"
fi
