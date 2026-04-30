# aliases — common shell aliases (navigation, files, network, system monitoring)

## Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."

## List directory content
alias ll="ls -Ahlo --time-style=long-iso --color=auto"
alias ls="ls -hlo --time-style=long-iso --color=auto"
alias l="ls -CF --color=auto"

## File operations
alias chgrp="chgrp -c --preserve-root"
alias chmod="chmod -c --preserve-root"
alias chown="chown -c --preserve-root"
alias cp="cp -iv"
alias mv="mv -iv"
alias ln="ln -i"
alias rm="rm -I --preserve-root"

## Network
alias wget="wget -c"
alias ports="netstat -tulanp"
alias myip="ip a | grep inet"
alias publicip="curl -s icanhazip.com || echo 'No internet connection'"

## General
alias c="clear"
alias grep="grep --color=auto"
alias watch="watch -d"
alias h='history'

## Package management (dnf / Fedora)
if command -v dnf >/dev/null 2>&1; then
  alias update='sudo dnf check-update'
  alias upgrade='sudo dnf upgrade'
  alias install='sudo dnf install'
  alias remove='sudo dnf remove'
  alias uplist='dnf list updates'
fi
