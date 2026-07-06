#!/bin/bash

if [ -z "${SWAYSOCK:-}" ]; then
    for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock; do
        if [ -S "$sock" ]; then
            export SWAYSOCK="$sock"
            break
        fi
    done
fi

if [ -n "${SWAYSOCK:-}" ] && [ -z "${I3SOCK:-}" ]; then
    export I3SOCK="$SWAYSOCK"
fi

if pgrep -x quickshell >/dev/null; then
    pkill quickshell
else
    nohup quickshell >/dev/null 2>&1 &
fi
