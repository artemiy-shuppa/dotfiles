# carapace — multi-shell completion bridge

autoload -U compinit && compinit

if command -v carapace &>/dev/null; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi
