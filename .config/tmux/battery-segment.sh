#!/bin/sh

set -eu

bar_bg=${1:?missing bar bg}
segment_bg=${2:?missing segment bg}
segment_fg=${3:?missing segment fg}

battery_output=$(sh "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/battery.sh" 2>/dev/null || true)
[ -n "$battery_output" ] || exit 0

printf '#[fg=%s,bg=%s]#[fg=%s,bg=%s] %s #[fg=%s,bg=%s] ' \
    "$segment_bg" \
    "$bar_bg" \
    "$segment_fg" \
    "$segment_bg" \
    "$battery_output" \
    "$segment_bg" \
    "$bar_bg"
