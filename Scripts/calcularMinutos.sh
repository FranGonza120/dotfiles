#!/bin/bash

# Verificar que se proporcionaron dos argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 HH:MM HH:MM"
    exit 1
fi

# Obtener las horas y minutos de los parámetros
hora_inicio="$1"
hora_fin="$2"

# Convertir horas a minutos
inicio_min=$(echo "$hora_inicio" | awk -F: '{print ($1 * 60) + $2}')
fin_min=$(echo "$hora_fin" | awk -F: '{print ($1 * 60) + $2}')

# Calcular la diferencia
diferencia=$((fin_min - inicio_min))

# Si la diferencia es negativa, significa que la hora fin es al día siguiente
if [ "$diferencia" -lt 0 ]; then
    diferencia=$((diferencia + 1440)) # 1440 minutos en un día
fi

echo "Diferencia en minutos: $diferencia"

