# keybindings — zsh key bindings

bindkey -e # sets emacs mode

# ── Navigation ────────────────────────────────────────────────────────────────
# ^A              beginning-of-line
# ^E              end-of-line
# ^B / ^F         backward-char / forward-char
# Alt+B / Alt+F   backward-word / forward-word
bindkey '^[[1~' beginning-of-line   # Home
bindkey '^[[4~' end-of-line         # End
bindkey '^[[5~' backward-word       # PgUp
bindkey '^[[6~' forward-word        # PgDn

# ── History ───────────────────────────────────────────────────────────────────
# ^R              fzf-history-widget  (fuzzy search)
# ^P / ^N         up/down-line-or-history
# Alt+.           insert-last-word    (repeat to go deeper)

# ── Editing ───────────────────────────────────────────────────────────────────
# ^W              backward-kill-word  (delete word before cursor)
# Alt+D           kill-word           (delete word after cursor)
# ^K              kill-line           (delete to end of line)
# ^U              kill-whole-line     (delete entire line)
# ^Y              yank                (paste from kill-ring)
# ^_              undo

# ── Screen ────────────────────────────────────────────────────────────────────
# ^L              clear-screen
