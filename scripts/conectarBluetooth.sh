#!/bin/bash

if [ -z "$1" ]; then
  echo "Por proporciona la clave del dispotivo que querés conectar"
  exit 1
fi

# Usar case para manejar las opciones
case "$1" in
  J)
    bluetoothctl connect 84:D3:52:C8:48:64
    ;;
  H)
    bluetoothctl connect E0:67:81:06:F9:94
    ;;
  S)
    bluetoothctl connect EE:E8:96:D5:61:85
    ;;
  *)
    echo "Utiliza: "  
    echo "J para conectarte a los JBL TUNE 770NC" 
    echo "H para conectarte a los Haylou GT1 Pro"
    echo "S para conectarte al SPIDER NAZI"
    ;;
esac

