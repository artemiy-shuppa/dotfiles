# mise — version manager activation and PATH setup for all managed tools

if command -v mise >/dev/null 2>&1; then
  eval "$(~/.local/bin/mise activate zsh)"
else
  print "[.zshrc] Warning: mise is not installed, skipping activation"
fi
