#!/bin/sh

set -eu

trim_output() {
    text=$1
    max_chars=${2:-48}

    if [ "$(printf '%s' "$text" | wc -m | tr -d ' ')" -le "$max_chars" ]; then
        printf '%s' "$text"
        return
    fi

    printf '%s…' "$(printf '%s' "$text" | cut -c1-"$((max_chars - 1))")"
}

if command -v osascript >/dev/null 2>&1; then
    track=$(
        osascript <<'APPLESCRIPT' 2>/dev/null || true
set trackInfo to ""
set bestTrackInfo to ""

if application "Safari" is running then
    tell application "Safari"
        if (count of windows) > 0 then
            repeat with safariWindow in windows
                repeat with safariTab in tabs of safariWindow
                    try
                        set trackInfo to do JavaScript "
                            (() => {
                                const media = Array.from(document.querySelectorAll('video, audio'));
                                const playingElement = media.find(item => !item.paused && !item.ended);
                                const metadata = navigator.mediaSession ? navigator.mediaSession.metadata : null;
                                const playbackState = navigator.mediaSession && navigator.mediaSession.playbackState ? navigator.mediaSession.playbackState : '';
                                const title = metadata && metadata.title ? metadata.title : '';
                                const artist = metadata && metadata.artist ? metadata.artist : '';
                                const pageTitle = document.title || '';
                                const info = title && artist ? `${title} — ${artist}` : (title || pageTitle);
                                if (!info) return '';
                                if (playingElement || playbackState === 'playing') return `2|${info}`;
                                if (metadata) return `1|${info}`;
                                return '';
                            })();
                        " in safariTab
                    on error
                        set trackInfo to ""
                    end try
                    
                    if trackInfo starts with "2|" then
                        return text 3 thru -1 of trackInfo
                    end if
                    
                    if trackInfo starts with "1|" and bestTrackInfo is "" then
                        set bestTrackInfo to text 3 thru -1 of trackInfo
                    end if
                end repeat
            end repeat
        end if
    end tell
end if

return bestTrackInfo
APPLESCRIPT
    )

    track=$(printf '%s' "$track" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    if [ -n "$track" ]; then
        trim_output "󰎈 $track" 30
        exit 0
    fi
fi

if command -v playerctl >/dev/null 2>&1; then
    status=$(playerctl status 2>/dev/null || true)
    if [ "$status" = "Playing" ]; then
        artist=$(playerctl metadata artist 2>/dev/null || true)
        title=$(playerctl metadata title 2>/dev/null || true)
        track=$(printf '%s — %s' "$title" "$artist" | sed 's/^ — //; s/ — $//')
        [ -n "$track" ] || exit 0
        trim_output "󰎈 $track" 30
        exit 0
    fi
fi

if command -v osascript >/dev/null 2>&1; then
    music_info=$(
        osascript <<'APPLESCRIPT' 2>/dev/null || true
if application "Music" is running then
    tell application "Music"
        try
            return "track=" & (name of current track as text) & " — " & (artist of current track as text)
        end try
    end tell
end if

return ""
APPLESCRIPT
    )

    case "$music_info" in
        *track=*)
            track=${music_info#*track=}
            ;;
        *)
            track=
            ;;
    esac
    track=$(printf '%s' "$track" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    [ -n "$track" ] || exit 0
    trim_output "󰎈 $track" 30
fi
