# prompt — starship prompt or custom PS1 fallback

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
