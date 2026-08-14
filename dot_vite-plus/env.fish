# Vite+ environment setup (https://viteplus.dev)
set -gx VP_HOME "$HOME/.vite-plus"
set -l __vp_idx (contains -i -- $HOME/.vite-plus/bin $PATH)
and set -e PATH[$__vp_idx]
set -gx PATH $HOME/.vite-plus/bin $PATH

# Shell function wrapper: intercepts `vp env use` to eval its stdout,
# which sets/unsets VP_NODE_VERSION in the current shell session.
function vp
    if test (count $argv) -ge 2; and test "$argv[1]" = "env"; and test "$argv[2]" = "use"
        if contains -- -h $argv; or contains -- --help $argv
            command vp $argv; return
        end
        set -lx VP_ENV_USE_EVAL_ENABLE 1
        set -lx VP_SHELL fish
        set -l __vp_out (command vp $argv); or return $status
        eval (string join ';' $__vp_out)
    else
        command vp $argv
    end
end

# Dynamic shell completion for fish
VP_COMPLETE=fish command vp | source

function __vpr_complete
    set -l tokens (commandline --current-process --tokenize --cut-at-cursor)
    set -l current (commandline --current-token)
    VP_COMPLETE=fish command vp -- vp run $tokens[2..] $current
end
complete -c vpr --keep-order --exclusive --arguments "(__vpr_complete)"
