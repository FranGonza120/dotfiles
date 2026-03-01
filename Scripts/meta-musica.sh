#!/bin/bash
cd ~/Escritorio/3.Recursos/Musica/BrainFm
for f in *.mp3; do
 ffmpeg -i "$f" -i ~/Descargas/brainfm.jpg \
  -map 0 -map 1 \
  -metadata artist="BrainFm" \
  -metadata album="BrainFm" \
  -c copy \
  -id3v2_version 3 \
  -disposition:v attached_pic \
  "tmp_$f"
  mv "tmp_$f" "$f"
done
