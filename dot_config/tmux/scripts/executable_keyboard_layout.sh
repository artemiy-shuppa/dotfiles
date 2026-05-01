#!/bin/bash
# Keyboard layout detection for tmux status bar.
# Supports: Niri WM (primary), X11/XWayland (fallback).

get_layout() {
    local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local -a _socks=("$runtime"/niri.*.sock)
    local niri_sock="${NIRI_SOCKET:-${_socks[0]}}"

    if [ -S "$niri_sock" ]; then
        NIRI_SOCKET="$niri_sock" niri msg --json keyboard-layouts 2>/dev/null \
            | jq -r '.names[.current_idx]' 2>/dev/null \
            | cut -c1-2 | tr '[:lower:]' '[:upper:]'
        return
    fi

    # X11 / XWayland fallback
    setxkbmap -query 2>/dev/null \
        | awk '/^layout/{split($2,a,","); print toupper(a[1])}' | cut -c1-2
}

get_layout
