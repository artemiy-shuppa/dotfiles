# fzf — fuzzy finder shell integration

if ! command -v fzf &>/dev/null; then
  return
fi

# Shell key bindings: Ctrl+R (history), Ctrl+T (files), Alt+C (cd)
source <(fzf --zsh)

# Use fd as backend if available: respects .gitignore, shows hidden files
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS='
  --height 50%
  --layout reverse
  --border rounded
  --info inline
  --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
'

# Ctrl+T: preview file contents
if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS='--preview "bat --color=always --line-range :200 {}"'
else
  export FZF_CTRL_T_OPTS='--preview "cat {}"'
fi

# Alt+C: preview directory tree
export FZF_ALT_C_OPTS='--preview "ls --color=always {}"'

# fzf-tab — replace zsh completion menu with fzf
_fzf_tab_dir="$HOME/.local/share/zsh/plugins/fzf-tab"
if [[ -d "$_fzf_tab_dir" ]]; then
  source "$_fzf_tab_dir/fzf-tab.zsh"

  # Preview for cd completions
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'

  # Preview file content in other completions
  if command -v bat &>/dev/null; then
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      'bat --color=always --line-range :200 $realpath 2>/dev/null || ls --color=always $realpath 2>/dev/null'
  fi
fi
unset _fzf_tab_dir
