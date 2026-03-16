function __fzf_jj_sh
    # Get the absolute path to the directory containing this script so we can
    # call fzf-jj.sh without needing it on $PATH.
    set --function fzf_jj_sh_path (realpath (status dirname))

    commandline --insert (SHELL=bash bash "$fzf_jj_sh_path/fzf-jj.sh" --run $argv | string join ' ')
    commandline -f repaint
end

# Ctrl-j Ctrl-f: jj file picker
# Note: Ctrl-j (^J, 0x0A) is also newline/LF. Fish treats chord prefixes with
# a short timeout before falling back to the single-key binding, so regular
# Enter (which sends ^M/CR, not ^J) is unaffected. Rapid ^J presses may have
# a brief delay. If this causes issues, rebind to a different chord prefix.
bind -M default \cj\cf '__fzf_jj_sh files'
bind -M insert  \cj\cf '__fzf_jj_sh files'
