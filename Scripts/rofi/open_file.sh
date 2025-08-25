#!/bin/bash

# Carpeta base de búsqueda
SEARCH_DIR="$HOME"
LIBREOFFICE="$HOME/Escritorio/3.Recursos/AppImages/LibreOffice.AppImage"
KOREADER="$HOME/Escritorio/3.Recursos/AppImages/Koreader.AppImage"

# Rutas que querés ocultar del menú de rofi
HIDE_PREFIXES=(
  "$HOME/Escritorio/1.Projectos/Universidad/"
  "$HOME/Escritorio/1.Projectos/"
  "$HOME/Escritorio/2.Areas/"
  "$HOME/Escritorio/3.Recursos/"
  "$HOME/Escritorio/4.Archivar/"
)

# Buscar archivos y guardarlos en un array
mapfile -t FILES < <(
  fd . "$SEARCH_DIR" -e pdf -e xls -e xlsx -e ods -e docx -e csv -e epub
)

# Limpiar las rutas que se van a mostrar
CLEANED_OPTIONS=("${FILES[@]}")
for prefix in "${HIDE_PREFIXES[@]}"; do
  CLEANED_OPTIONS=("${CLEANED_OPTIONS[@]/$prefix/}")
done

# Mostrar en Rofi y obtener el índice
OPTIONS=$(printf '%s\n' "${CLEANED_OPTIONS[@]}")
SELECTED_INDEX=$(echo "$OPTIONS" | rofi -dmenu -p "Abrir archivo" -format i)

# Cancelar si no se eligió nada
[ -z "$SELECTED_INDEX" ] && exit 0

# Obtener el archivo real seleccionado
SELECTED_FILE="${FILES[$SELECTED_INDEX]}"

# Abrir según tipo
case "$SELECTED_FILE" in
  *.pdf) okular "$SELECTED_FILE" ;;
  *.xls|*.xlsx|*.ods|*.csv|*.docx) "$LIBREOFFICE" "$SELECTED_FILE" ;;
  *.epub) "$KOREADER" "$SELECTED_FILE";;
  *) xdg-open "$SELECTED_FILE" ;;
esac
