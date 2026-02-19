#!/bin/bash

read -rp "Conecte el dispositivo por USB y active el debugging por USB. Cuando este listo presionte Enter."

scrcpy \
--video-bit-rate 25M \
--max-size 0 \
--max-fps 60 \
--video-codec=h264 \
--render-driver=opengl
