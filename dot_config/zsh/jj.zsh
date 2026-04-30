# jj — jujutsu wrapper with pre-commit integration and CI watch on push

(( $+commands[jj] )) || return

JJ_PRECOMMIT_INTEGRATION=true
JJ_CI_WATCH=true

jj() {
  local need_check=false need_push_check=false need_ci_watch=false

  case "$1" in
    commit|new|cm) need_check=true ;;  # cm = jj alias for commit; keep in sync with jj config aliases
    push)          need_push_check=true; need_ci_watch=true ;;
    git)           [[ "$2" == push ]] && { need_push_check=true; need_ci_watch=true } ;;
  esac

  _jj_pre_commit_installed() {
    (( $+commands[pre-commit] )) && return 0
    print -u2 '-----'
    print -u2 'pre-commit is not installed.'
    print -u2 'Install it via mise or pipx'
    print -u2 'Or disable: JJ_PRECOMMIT_INTEGRATION=false'
    print -u2 '-----'
    return 1
  }

  _jj_is_wip() { [[ "${1:l}" == *wip* ]] }

  _jj_mark_wip() {
    command jj desc -r @ -m "[WIP]: $1"
    print '  Marked as [WIP] — protected from push'
  }

  _jj_run_pre_commit() {
    print 'Running pre-commit checks...'
    local desc="$1" files choice

    while true; do
      files="$(command jj diff --name-only)"

      if [[ -z $files ]]; then
        print 'Nothing to check'
        return 0
      fi

      # ${=files} performs zsh word-splitting on newlines to build the file list
      if pre-commit run --files ${=files}; then
        print 'Pre-commit passed'
        return 0
      fi

      print
      print '  Pre-commit checks failed!'
      print '  1) Retry'
      print '  2) Mark as [WIP] (blocked from push)'
      print '  3) Continue anyway (risky!)'
      print '  4) Abort'
      print -u2 '  Or disable: JJ_PRECOMMIT_INTEGRATION=false'
      read -r "choice?Choice [1/2/3/4]: "

      case "$choice" in
        1) print 'Retrying...' ;;
        2) _jj_mark_wip "$desc"; return 0 ;;
        3) print '  Continuing without [WIP] mark'; return 0 ;;
        4) print '  Aborted'; return 1 ;;
        *) print 'Invalid choice — marking as [WIP]'; _jj_mark_wip "$desc"; return 0 ;;
      esac
    done
  }

  _jj_run_pre_commit_all() {
    print 'Running pre-commit on all files before push...'
    local choice

    while true; do
      if pre-commit run --all-files; then
        print 'Pre-commit passed'
        return 0
      fi

      print
      print '  Pre-commit checks failed!'
      print '  1) Retry'
      print '  2) Push anyway (risky!)'
      print '  3) Abort'
      print -u2 '  Or disable: JJ_PRECOMMIT_INTEGRATION=false'
      read -r "choice?Choice [1/2/3]: "

      case "$choice" in
        1) print 'Retrying...' ;;
        2) print '  Pushing without passing pre-commit'; return 0 ;;
        3) print '  Aborted'; return 1 ;;
        *) print 'Invalid choice — aborting'; return 1 ;;
      esac
    done
  }

  # unsets itself and all helpers — call on every exit path
  _jj_cleanup() {
    unset -f _jj_pre_commit_installed _jj_is_wip _jj_mark_wip \
              _jj_run_pre_commit _jj_run_pre_commit_all _jj_cleanup
  }

  local repo_root
  repo_root="$(command jj root 2>/dev/null)"
  local in_jj_repo=$(( $? == 0 ))

  local have_pre_commit_config=false
  if (( in_jj_repo )) && [[ -f "$repo_root/.pre-commit-config.yaml" || -f "$repo_root/.pre-commit-config.yml" ]]; then
    have_pre_commit_config=true
  fi

  if [[ $JJ_PRECOMMIT_INTEGRATION == true ]] && [[ $have_pre_commit_config == true ]]; then
    if [[ $need_check == true ]] && _jj_pre_commit_installed; then
      local desc
      desc="$(command jj log -r @ -T description --no-graph)"

      if _jj_is_wip "$desc"; then
        print '  Commit contains WIP — skipping pre-commit'
      else
        _jj_run_pre_commit "$desc" || { _jj_cleanup; return 1 }
      fi
    fi

    if [[ $need_push_check == true ]] && _jj_pre_commit_installed; then
      _jj_run_pre_commit_all || { _jj_cleanup; return 1 }
    fi
  fi

  _jj_cleanup

  command jj "$@"
  local jj_exit=$?

  if (( jj_exit == 0 )) \
      && [[ $JJ_CI_WATCH == true ]] \
      && [[ $need_ci_watch == true ]] \
      && (( $+commands[gh] )) \
      && gh auth token &>/dev/null; then
    local watch_root="$repo_root"
    (
      sleep 5
      cd "$watch_root" || exit
      local run_id
      run_id="$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)"
      [[ -z $run_id ]] && exit
      gh run watch "$run_id" --exit-status &>/dev/null
      if (( $? == 0 )); then
        notify-send 'CI Passed ✓' "$(basename "$watch_root")" --icon=dialog-ok
      else
        notify-send 'CI Failed ✗' "$(basename "$watch_root")" --icon=dialog-error -u critical
      fi
    ) &!
    print '  Watching CI run in background...'
  fi

  return $jj_exit
}
