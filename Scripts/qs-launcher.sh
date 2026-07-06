#!/bin/bash

MODE="${1:-apps}"
COMMAND_FILE="/tmp/quickshell-launcher-mode"

case "$MODE" in
  apps|files|wallpapers) ;;
  *) exit 1 ;;
esac

printf '%s\n' "$MODE" > "$COMMAND_FILE"
