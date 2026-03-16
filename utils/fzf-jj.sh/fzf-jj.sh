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
  files) _fzf_jj_files ;;
esac

fi # -------------------------------------------------------------------------
