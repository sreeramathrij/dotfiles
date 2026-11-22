#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/neobrix"
STATE_FILE="$STATE_DIR/wallpaper"
LOCK_BG="$STATE_DIR/lock-background.png"

[[ -s "$STATE_FILE" ]] || {
    echo "No wallpaper selected" >&2
    exit 1
}

WALL="$(cat "$STATE_FILE")"

[[ -f "$WALL" ]] || {
    echo "Wallpaper not found: $WALL" >&2
    exit 1
}

mkdir -p "$STATE_DIR"

# Generate a real PNG regardless of input format.
# Temporary output preserves the previous valid image
# if decoding fails.
TMP="$(mktemp "$STATE_DIR/.lock-background.XXXXXXXX.png")"
trap 'rm -f -- "$TMP"' EXIT

ffmpeg -hide_banner -loglevel error \
    -nostdin -y \
    -i "$WALL" \
    -map 0:v:0 \
    -frames:v 1 \
    -vf "scale='min(1920,iw)':-2:flags=lanczos,format=rgb24" \
    -f image2 -update 1 \
    "$TMP"

[[ -s "$TMP" ]] || exit 1

chmod 600 "$TMP"
mv -f -- "$TMP" "$LOCK_BG"

echo "Lock background updated: $LOCK_BG"
