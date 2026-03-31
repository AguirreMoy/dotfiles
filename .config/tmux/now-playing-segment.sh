#!/bin/sh

set -eu

bar_bg=${1:?missing bar bg}
music_bg=${2:?missing music bg}
music_fg=${3:?missing music fg}
time_bg=${4:?missing time bg}
time_fg=${5:?missing time fg}

music_output=$(sh "$HOME/.config/tmux/now-playing.sh" 2>/dev/null || true)
time_output=$(date '+%H:%M')

if [ -n "$music_output" ]; then
    printf '#[fg=%s,bg=%s]#[fg=%s,bg=%s] %s #[fg=%s,bg=%s]#[fg=%s,bg=%s,bold] 󰥔 %s #[fg=%s,bg=%s]' \
        "$music_bg" \
        "$bar_bg" \
        "$music_fg" \
        "$music_bg" \
        "$music_output" \
        "$time_bg" \
        "$music_bg" \
        "$time_fg" \
        "$time_bg" \
        "$time_output" \
        "$time_bg" \
        "$bar_bg"
    exit 0
fi

printf '#[fg=%s,bg=%s]#[fg=%s,bg=%s,bold] 󰥔 %s #[fg=%s,bg=%s]' \
    "$time_bg" \
    "$bar_bg" \
    "$time_fg" \
    "$time_bg" \
    "$time_output" \
    "$time_bg" \
    "$bar_bg"
