# zoxide — smart cd replacement (falls back to cdspell if not installed)

# initialize zoxide if it installed
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
  alias z=cd
else
  # correct simple errors while using cd
  shopt -s cdspell
fi
