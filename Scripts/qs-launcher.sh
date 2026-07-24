#!/bin/bash

MODE="${1:-apps}"
COMMAND_FILE="/tmp/quickshell-launcher-mode"
QS_BIN="$(command -v qs || command -v quickshell)"

[ -n "$QS_BIN" ] || exit 1

case "$MODE" in
  apps|files|wallpapers) ;;
  *) exit 1 ;;
esac

case "$MODE" in
  apps)
    exec "$QS_BIN" ipc call launcher openApps
    ;;
  files)
    exec "$QS_BIN" ipc call launcher openFiles
    ;;
  wallpapers)
    printf '%s\n' "$MODE" > "$COMMAND_FILE"
    ;;
esac
