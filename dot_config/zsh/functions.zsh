# functions — utility shell functions (extract, md, path, e, se, version)

# Open files in $EDITOR
e() {
  ${EDITOR:-vi} "$@"
}

# Edit files with sudo
se() {
  if [ $# -eq 0 ]; then
    echo "Usage: se <file> [files...]" >&2
    return 1
  fi

  if command -v sudoedit >/dev/null 2>&1; then
    sudoedit "$@"
  else
    sudo "${EDITOR:-vi}" "$@"
  fi
}

# extract archive
extract() {
  local file="$1"

  if [[ -f "$file" ]]; then
    case "$file" in
    *.tar.bz2) tar xjf "$file" ;;
    *.tar.gz) tar xzf "$file" ;;
    *.bz2) bunzip2 "$file" ;;
    *.rar) unrar x "$file" ;;
    *.gz) gunzip "$file" ;;
    *.tar) tar xf "$file" ;;
    *.tbz2) tar xjf "$file" ;;
    *.tgz) tar xzf "$file" ;;
    *.zip) unzip "$file" ;;
    *.Z) uncompress "$file" ;;
    *.7z) 7z x "$file" ;;
    *.ace) unace x "$1" ;;

    *) echo "'$file' cannot be extracted via extract()" ;;
    esac
  else
    echo "$file is not a valid file"
  fi
}

# check command exist and try to get its version
version() {
  local cmd="$1"

  if [[ -z "$cmd" ]]; then
    echo "Usage: version <command>" >&2
    return 1
  fi

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd found: $(command -v "$cmd")"
    # Try common version flags
    "$cmd" --version 2>/dev/null ||
      "$cmd" -version 2>/dev/null ||
      "$cmd" -V 2>/dev/null ||
      "$cmd" -v 2>/dev/null ||
      "$cmd" version 2>/dev/null ||
      echo "  (version info not available)" >&2
  else
    echo "$cmd not found" >&2
    return 1
  fi
}

# make directory then go there (if nothing pass creates temporary directory)
md() {
  local dir="$1"

  if [ -n "$dir" ]; then
    mkdir -p -- "$dir"
  else
    dir=$(mktemp -d)
    echo "Created temporary $dir directory"
  fi

  cd -- "$dir" || return 1
}

# which package manager owns this executable (detected by install path)
whichpm() {
  if [[ -z "$1" ]]; then
    print "Usage: whichpm <command>" >&2
    return 1
  fi

  local cmd_path
  cmd_path=$(whence -p "$1" 2>/dev/null)
  if [[ -z "$cmd_path" ]]; then
    print "whichpm: '$1' not found (or is a shell function/builtin with no backing binary)" >&2
    return 1
  fi

  local real_path
  real_path=$(realpath "$cmd_path" 2>/dev/null || readlink -f "$cmd_path")

  print "  command: $cmd_path"
  [[ "$real_path" != "$cmd_path" ]] && print "  real:    $real_path"

  case "$real_path" in
    $HOME/.local/share/mise/*)  print "  manager: mise" ;;
    $HOME/.cargo/bin/*)         print "  manager: cargo (standalone)" ;;
    $HOME/.local/share/pipx/*)  print "  manager: pipx (standalone)" ;;
    $HOME/.npm/*|$HOME/.local/share/npm/*) print "  manager: npm (global, standalone)" ;;
    /usr/bin/*|/usr/sbin/*|/bin/*|/sbin/*) print "  manager: dnf (system)" ;;
    /usr/local/bin/*|/usr/local/sbin/*)    print "  manager: manual (/usr/local)" ;;
    /snap/bin/*)                print "  manager: snap" ;;
    /nix/store/*)               print "  manager: nix" ;;
    /var/lib/flatpak/*|$HOME/.local/share/flatpak/*) print "  manager: flatpak" ;;
    *)                          print "  manager: unknown ($real_path)" ;;
  esac
}

# make script file
ms() {
  local file="$1"

  if [ -n "$file" ]; then
    echo "Failed to create script" >&2
    return 1
  fi

  touch "$file" && chmod u+x "$file"
}
