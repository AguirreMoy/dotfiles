#!/bin/sh

set -eu

print_battery() {
    percent=$1
    state=$2

    icon="󰁹"
    case "$state" in
        charging)
            icon="󰂄"
            ;;
        full)
            icon="󰁹"
            ;;
        *)
            if [ "$percent" -ge 90 ]; then
                icon="󰁹"
            elif [ "$percent" -ge 70 ]; then
                icon="󰂀"
            elif [ "$percent" -ge 50 ]; then
                icon="󰁿"
            elif [ "$percent" -ge 30 ]; then
                icon="󰁾"
            elif [ "$percent" -ge 10 ]; then
                icon="󰁼"
            else
                icon="󰁺"
            fi
            ;;
    esac

    printf '%s %s%%' "$icon" "$percent"
}

if command -v pmset >/dev/null 2>&1; then
    line=$(pmset -g batt | awk 'NR==2 {print}')
    [ -n "$line" ] || exit 0

    percent=$(printf '%s\n' "$line" | sed -n 's/.* \([0-9][0-9]*\)%.*/\1/p')
    [ -n "$percent" ] || exit 0

    state="discharging"
    case "$line" in
        *"AC Power"*) state="charging" ;;
        *"; charged;"*|*"finishing charge"*) state="full" ;;
    esac

    print_battery "$percent" "$state"
    exit 0
fi

if command -v upower >/dev/null 2>&1; then
    battery_device=$(upower -e 2>/dev/null | grep battery | head -n 1 || true)
    [ -n "$battery_device" ] || exit 0

    info=$(upower -i "$battery_device" 2>/dev/null || true)
    percent=$(printf '%s\n' "$info" | sed -n 's/^[[:space:]]*percentage:[[:space:]]*\([0-9][0-9]*\)%.*/\1/p')
    state=$(printf '%s\n' "$info" | sed -n 's/^[[:space:]]*state:[[:space:]]*\(.*\)$/\1/p')
    [ -n "$percent" ] || exit 0

    case "$state" in
        charging|fully-charged) ;;
        *) state="discharging" ;;
    esac

    [ "$state" = "fully-charged" ] && state="full"
    print_battery "$percent" "$state"
    exit 0
fi

if command -v acpi >/dev/null 2>&1; then
    line=$(acpi -b 2>/dev/null | head -n 1 || true)
    [ -n "$line" ] || exit 0

    percent=$(printf '%s\n' "$line" | sed -n 's/.* \([0-9][0-9]*\)%.*/\1/p')
    [ -n "$percent" ] || exit 0

    state="discharging"
    case "$line" in
        *Charging*) state="charging" ;;
        *Full*) state="full" ;;
    esac

    print_battery "$percent" "$state"
fi
