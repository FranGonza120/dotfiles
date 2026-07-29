#!/bin/sh

set -eu

other_output() {
    case "$1" in
        HDMI-A-1) printf '%s\n' eDP-1 ;;
        eDP-1) printf '%s\n' HDMI-A-1 ;;
        *) return 1 ;;
    esac
}

if [ "${1-}" = "--self-test" ]; then
    [ "$(other_output HDMI-A-1)" = "eDP-1" ]
    [ "$(other_output eDP-1)" = "HDMI-A-1" ]
    exit 0
fi

# ponytail: asume dos outputs fijos; si cambian los nombres, leerlos desde get_outputs.
if ! swaymsg -t get_outputs | awk '
    /"name": "HDMI-A-1"/ { hdmi = 1 }
    hdmi && /"active": true/ { found = 1; exit }
    /^[[:space:]]*}/ { hdmi = 0 }
    END { exit(found ? 0 : 1) }
' >/dev/null; then
    exit 0
fi

current_output="$(
    swaymsg -t get_outputs | awk '
        /"name":/ { gsub(/[",]/, "", $2); name = $2 }
        /"focused": true/ { print name; exit }
    '
)"

target_output="$(other_output "$current_output")" || exit 0
exec swaymsg move workspace to output "$target_output"
