#!/usr/bin/env bash

# Setup variables
time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"
file="${dir}/Screenshot_${time}_${RANDOM}.png"
mkdir -p "$dir"

MODE=$1

# Determine geometry
if [[ "$MODE" == "area" ]]; then
    geom=$(slurp)
    if [[ -z "$geom" ]]; then exit 1; fi
elif [[ "$MODE" == "active" ]]; then
    geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    if [[ -z "$geom" || "$geom" == "null" ]]; then exit 1; fi
elif [[ "$MODE" == "screen" ]]; then
    geom=""
else
    echo "Usage: $0 {area|active|screen}"
    exit 1
fi

# Capture and save to file
if [[ -n "$geom" ]]; then
    grim -g "$geom" "$file"
else
    grim "$file"
fi

# Verify file was created
if [[ ! -f "$file" ]]; then
    exit 1
fi

# Copy to clipboard
wl-copy < "$file"

# Open in swappy (background)
swappy -f "$file" &

# Play screenshot sound if it exists
if [[ -x "$HOME/.config/hypr/scripts/Sounds.sh" ]]; then
    "$HOME/.config/hypr/scripts/Sounds.sh" --screenshot >/dev/null 2>&1 &
fi
