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

pkill -x quickshell 2>/dev/null || true
nohup quickshell >/dev/null 2>&1 &
