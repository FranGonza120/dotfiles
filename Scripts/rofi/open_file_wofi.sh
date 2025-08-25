#!/bin/bash

# Carpeta base de búsqueda
SEARCH_DIR="$HOME"
LIBREOFFICE="$HOME/Escritorio/3.Recursos/AppImages/LibreOffice.AppImage"
KOREADER="$HOME/Escritorio/3.Recursos/AppImages/Koreader.AppImage"

# Rutas a ocultar del menú
HIDE_PREFIXES=(
  "$HOME/Escritorio/1.Projectos/Universidad/"
  "$HOME/Escritorio/1.Projectos/"
  "$HOME/Escritorio/2.Areas/"
  "$HOME/Escritorio/3.Recursos/"
  "$HOME/Escritorio/4.Archivar/"
)

# Buscar archivos
mapfile -t FILES < <(
  fd . "$SEARCH_DIR" -e pdf -e xls -e xlsx -e ods -e docx -e csv -e epub
)

# Limpiar rutas para mostrar
CLEANED_OPTIONS=("${FILES[@]}")
for prefix in "${HIDE_PREFIXES[@]}"; do
  CLEANED_OPTIONS=("${CLEANED_OPTIONS[@]/$prefix/}")
done

# Mostrar opciones en Wofi
OPTIONS=$(printf '%s\n' "${CLEANED_OPTIONS[@]}")
SELECTED=$(echo "$OPTIONS" | wofi -W 75% -s ~/.config/wofi/file.css --show dmenu --prompt "Abrir archivo")

# Cancelar si no se eligió nada
[ -z "$SELECTED" ] && exit 0

# Buscar el índice original
for i in "${!CLEANED_OPTIONS[@]}"; do
  if [[ "${CLEANED_OPTIONS[$i]}" == "$SELECTED" ]]; then
    SELECTED_FILE="${FILES[$i]}"
    break
  fi
done

# Abrir según tipo
case "$SELECTED_FILE" in
  *.pdf) okular "$SELECTED_FILE" ;;
  *.xls|*.xlsx|*.ods|*.csv|*.docx) "$LIBREOFFICE" "$SELECTED_FILE" ;;
  *.epub) "$KOREADER" "$SELECTED_FILE" ;;
  *) xdg-open "$SELECTED_FILE" ;;
esac

