#!/bin/bash
# Reload QuickShell

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

# Kill existing instance gracefully first, then force if needed
if pgrep -x quickshell > /dev/null; then
    echo "Stopping QuickShell..."
    pkill quickshell
    # Wait up to 5 seconds
    for i in {1..50}; do
        if ! pgrep -x quickshell > /dev/null; then
            break
        fi
        sleep 0.1
    done
    # Force kill if still running
    if pgrep -x quickshell > /dev/null; then
        pkill -9 quickshell
    fi
fi

# Start new instance
echo "Starting QuickShell..."
nohup quickshell > /dev/null 2>&1 &

echo "Done."
