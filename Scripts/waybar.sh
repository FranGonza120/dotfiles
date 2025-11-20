#!/bin/bash

if pgrep -x waybar > /dev/null; then
    killall waybar 2>/dev/null
else
    waybar &
fi

