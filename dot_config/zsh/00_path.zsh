# path — configuration and functions

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

prepend_path() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH" }
append_path()  { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$PATH:$1" }
path_list() {
  local entries
  entries=$(echo "$PATH" | tr ':' '\n')
  [[ "$1" == "--all" ]] || entries=$(echo "$entries" | grep -v "$HOME/.local/share/mise/installs/")
  echo "$entries"
}

prepend_path "$HOME/.local/bin"
