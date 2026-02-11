#!/bin/bash

read -p "Active el Debuggin Inalámbrico. Ponga la IP de su dispositivo como primer argumento y ponga el nro del puerto como segundo argumento. Si está preparado presione Enter." IP PUERTO

adb connect $IP:$PUERTO

scrcpy --video-bit-rate 12M --max-fps 60 --display-buffer=80
