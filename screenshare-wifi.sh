#!/bin/bash

read -rp "Ponga la IP de su dispositivo como argumento y ponga el proceso en el puerto 5555. Si está preparado presione Enter." _

adb connect $1:5555

scrcpy --video-bit-rate 12M --max-fps 60 --display-buffer=80
