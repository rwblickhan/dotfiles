#!/usr/bin/env bash
# fzf-jj.sh - fzf integration for jujutsu (jj)
# Requires jj 0.21+ (for `jj file list` and `jj diff --name-only`)

# shellcheck disable=SC2039
[[ $0 == - ]] && return

__fzf_jj_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  else
    echo "${FZF_JJ_COLOR:-always}"
  fi
}

__fzf_jj_cat() {
  if [[ -n $FZF_JJ_CAT ]]; then
    echo "$FZF_JJ_CAT"
    return
  fi

  local bat_opts="--style='${BAT_STYLE:-full}' --color=always --pager=never"
  if command -v batcat > /dev/null; then
    echo "batcat $bat_opts"
  elif command -v bat > /dev/null; then
    echo "bat $bat_opts"
  else
    echo cat
  fi
}

if [[ $- =~ i ]] || [[ $1 = --run ]]; then # ----------------------------------

if [[ $__fzf_jj_fzf ]]; then
  eval "$__fzf_jj_fzf"
else
  # Redefine this function to change the options
  _fzf_jj_fzf() {
    fzf --height 50% --tmux 90%,70% \
      --layout reverse --multi --min-height 20+ --border \
      --no-separator --header-border horizontal \
      --border-label-pos 2 \
      --color 'label:blue' \
      --preview-window 'right,50%' --preview-border line \
      --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
  }
fi

_fzf_jj_check() {
  jj root > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a jj repository"
  return 1
}

__fzf_jj=${BASH_SOURCE[0]:-${(%):-%x}}
__fzf_jj=$(readlink -f "$__fzf_jj" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_jj" 2> /dev/null)

_fzf_jj_help() {
  local cmd
  cmd=$(printf '%-12s %-16s %s\n' \
    'bookmarks'  'ctrl-j ctrl-b'  'Browse bookmarks' \
    'files'      'ctrl-j ctrl-f'  'Browse files' \
    'log'        'ctrl-j ctrl-l'  'Browse revision log' \
    'ops'        'ctrl-j ctrl-o'  'Browse operation log' \
    'remotes'    'ctrl-j ctrl-r'  'Browse git remotes' \
    'tags'       'ctrl-j ctrl-t'  'Browse tags' \
    'workspaces' 'ctrl-j ctrl-w'  'Browse workspaces' \
  | fzf --height 50% --tmux 90%,70% \
      --layout reverse --no-multi --min-height 20+ --border \
      --no-separator --header-border horizontal \
      --border-label-pos 2 \
      --color 'label:blue' \
      --border-label '⌨ fzf-jj ' \
      --header 'Select a picker' \
      --no-preview \
  | awk '{print $1}')
  case "$cmd" in
    bookmarks)  _fzf_jj_bookmarks ;;
    files)      _fzf_jj_files ;;
    log)        _fzf_jj_log ;;
    ops)        _fzf_jj_ops ;;
    remotes)    _fzf_jj_remotes ;;
    tags)       _fzf_jj_tags ;;
    workspaces) _fzf_jj_workspaces ;;
  esac
}

_fzf_jj_log() {
  _fzf_jj_check || return

  jj log --no-graph --color=never \
    -T 'change_id.short(8) ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"' \
    2>/dev/null | \
    _fzf_jj_fzf \
      --border-label '📜 Log ' \
      --header 'ENTER to insert change ID' \
      --preview "
        change=\"\$(echo {} | awk '{print \$1}')\"
        jj show --color=$(__fzf_jj_color) \"\$change\" 2>/dev/null
      " "$@" | \
    awk '{print $1}'
}

_fzf_jj_ops() {
  _fzf_jj_check || return

  jj op log --no-graph --color=never \
    -T 'id.short(8) ++ " " ++ description ++ "\n"' \
    2>/dev/null | \
    _fzf_jj_fzf \
      --border-label '⚙ Operations ' \
      --header 'ENTER to insert operation ID' \
      --preview "
        op=\"\$(echo {} | awk '{print \$1}')\"
        jj op show --color=$(__fzf_jj_color) \"\$op\" 2>/dev/null
      " "$@" | \
    awk '{print $1}'
}

_fzf_jj_remotes() {
  _fzf_jj_check || return

  jj git remote list 2>/dev/null | \
    _fzf_jj_fzf \
      --border-label '🌐 Remotes ' \
      --header 'ENTER to insert remote name' \
      --preview "
        remote=\"\$(echo {} | awk '{print \$1}')\"
        jj bookmark list --all --color=$(__fzf_jj_color) 2>/dev/null | grep \"@\${remote}\"
      " "$@" | \
    awk '{print $1}'
}

_fzf_jj_bookmarks() {
  _fzf_jj_check || return

  jj bookmark list --color=$(__fzf_jj_color) 2>/dev/null | \
    grep -v '^\s' | \
    _fzf_jj_fzf \
      --border-label '🔖 Bookmarks ' \
      --header 'ENTER to insert bookmark name' \
      --ansi \
      --preview "
        bookmark=\"\$(echo {} | cut -d: -f1)\"
        jj log --color=$(__fzf_jj_color) -r \"\$bookmark\" 2>/dev/null
      " "$@" | \
    cut -d: -f1
}

_fzf_jj_tags() {
  _fzf_jj_check || return

  jj tag list --color=$(__fzf_jj_color) 2>/dev/null | \
    _fzf_jj_fzf \
      --border-label '🏷 Tags ' \
      --header 'ENTER to insert tag name' \
      --ansi \
      --preview "
        tag=\"\$(echo {} | cut -d: -f1)\"
        jj log --color=$(__fzf_jj_color) -r \"\$tag\" 2>/dev/null
      " "$@" | \
    cut -d: -f1
}

_fzf_jj_workspaces() {
  _fzf_jj_check || return

  jj workspace list --color=$(__fzf_jj_color) 2>/dev/null | \
    _fzf_jj_fzf \
      --border-label '🗂 Workspaces ' \
      --header 'ENTER to insert workspace name' \
      --ansi \
      --preview "
        workspace=\"\$(echo {} | cut -d: -f1)\"
        jj log --color=$(__fzf_jj_color) -r \"\${workspace}@\" 2>/dev/null
      " "$@" | \
    cut -d: -f1
}

_fzf_jj_files() {
  _fzf_jj_check || return
  local root
  root=$(jj root 2>/dev/null)

  # All lines use a consistent 3-char prefix so `cut -c4-` extracts the path:
  #   Changed files:   "{status}  path"  e.g. "M  src/foo.rs"
  #   Unchanged files: "   path"         e.g. "   src/bar.rs"
  #
  # `jj diff --summary` format: "{M|A|D} path"
  # awk pads the status char to 3 chars: "M  " then appends the path (from col 3)
  (
    jj diff --summary --color=never 2>/dev/null | \
      awk '{printf "%-3s%s\n", substr($0,1,1), substr($0,3)}'
    jj file list 2>/dev/null | \
      grep -vxFf <(
        jj diff --name-only --color=never 2>/dev/null
        echo :
      ) | sed 's/^/   /'
  ) | \
    _fzf_jj_fzf -m \
      --border-label '📁 Files ' \
      --header 'ALT-E (open in editor)' \
      --bind "alt-e:execute:${EDITOR:-vim} \"\$(echo {} | cut -c4-)\"" \
      --preview "
        filepath=\"\$(echo {} | cut -c4-)\"
        diff_out=\"\$(cd \"\$root\" && jj diff --color=$(__fzf_jj_color) -- \"\$filepath\" 2>/dev/null)\"
        if [ -n \"\$diff_out\" ]; then
          echo \"\$diff_out\"
          echo '────'
        fi
        $(__fzf_jj_cat) \"\$root/\$filepath\" 2>/dev/null
      " "$@" | \
    cut -c4-
}

[[ $1 == --run ]] && shift
case "$1" in
  bookmarks)  _fzf_jj_bookmarks ;;
  files)      _fzf_jj_files ;;
  help)       _fzf_jj_help ;;
  log)        _fzf_jj_log ;;
  ops)        _fzf_jj_ops ;;
  remotes)    _fzf_jj_remotes ;;
  tags)       _fzf_jj_tags ;;
  workspaces) _fzf_jj_workspaces ;;
esac

fi # -------------------------------------------------------------------------
