#!/bin/bash
# Output system clipboard to stdout (Wayland or X11).
if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-paste &>/dev/null; then
    wl-paste --no-newline
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard -o
elif command -v xsel &>/dev/null; then
    xsel --clipboard --output
fi
