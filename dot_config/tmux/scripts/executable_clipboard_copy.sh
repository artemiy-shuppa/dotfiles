#!/bin/bash
# Write stdin to system clipboard (Wayland or X11).
if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy &>/dev/null; then
    wl-copy
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard
elif command -v xsel &>/dev/null; then
    xsel --clipboard --input
fi
