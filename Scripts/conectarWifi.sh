#!/bin/bash

listar_redes() {
	echo "Redes WiFi disponibles:"
	nmcli dev wifi list
}

conectar_red() {
	echo " Introduce el nombre de la red (SSID): "
	read ssid
	echo "Introduce la contraseña: "
	read -s password

	if [ -z "$password" ]; then 
		ncmli dev wifi connect "$ssid" 
	else 
		nmcli dev wifi connect "$ssid" password "$password"
	fi

	if [ $? -eq 0 ]; then 
		echo "Conexión exitosa a $ssid"
	else
		echo "Error al intentar conectar a $ssid"
	fi
}

listar_redes
conectar_red

