function setup_jj_hooks --description 'Add a jj-hooks setup hook that symlinks node_modules from the invocation workspace'
    argparse h/help f/force -- $argv
    or return 1

    if set -q _flag_help
        echo "setup_jj_hooks - add a jj-hooks setup hook to the current repo's jj config"
        echo ""
        echo "Adds a [[jj-hooks.setup]] hook that symlinks every node_modules tree in the"
        echo "invocation workspace (\$JJ_HOOKS_WORKSPACE) into each newly created workspace,"
        echo "instead of hardlink-copying them. Instant vs. hundreds of thousands of link()"
        echo "syscalls."
        echo ""
        echo "Every node_modules, not just the repo root: pnpm's isolated node-linker keeps"
        echo "each workspace package's deps and bins in that package's own node_modules."
        echo ""
        echo "The shared trees are READ-ONLY: never run an install in a hook'd workspace, or"
        echo "it will mutate the source workspace's node_modules. Intended for lint-only"
        echo "workspaces."
        echo ""
        echo "Usage:"
        echo "  setup_jj_hooks [options]"
        echo ""
        echo "Options:"
        echo "  -f, --force   Rewrite the hook even if one named 'share node_modules' exists"
        echo "  -h, --help    Show this help"
        echo ""
        echo "Run from inside the target jj repo. Writes to \`jj config path --repo\`."
        return 0
    end

    if not command -v jj &>/dev/null
        echo (set_color red)"Error: jj is not installed"(set_color normal)
        return 1
    end

    set -l helper (command -v jj-hooks-share-node-modules)
    if test -z "$helper"
        echo (set_color red)"Error: jj-hooks-share-node-modules is not on PATH (run \`chezmoi apply\`)"(set_color normal)
        return 1
    end

    if not jj root --quiet &>/dev/null
        echo (set_color red)"Error: not inside a jj repository"(set_color normal)
        return 1
    end

    set -l config_path (jj config path --repo 2>/dev/null)
    if test -z "$config_path"
        echo (set_color red)"Error: could not resolve repo config path"(set_color normal)
        return 1
    end

    set -l existing_run
    if test -e "$config_path"
        set existing_run (jj config get jj-hooks.setup 2>/dev/null | string match -r 'name = "share node_modules".*?run = \[[^]]*\]')
    end

    if test -n "$existing_run"
        if string match -q "*$helper*" -- "$existing_run"; and not set -q _flag_force
            echo (set_color yellow)"⊘ Hook 'share node_modules' already up to date in $config_path"(set_color normal)
            return 0
        end

        # Drop the old block (and the comment lines introducing it) so re-running
        # converges instead of appending a second hook with the same name.
        set -l stripped (mktemp)
        awk '
            {
                line = $0
                if (inblock) {
                    if (line ~ /^\[/) {
                        if (!drop) for (i = 1; i <= nb; i++) print blk[i]
                        inblock = 0; nb = 0; drop = 0
                    } else {
                        blk[++nb] = line
                        if (line ~ /^name = "share node_modules"/) drop = 1
                        next
                    }
                }
                if (line ~ /^\[\[jj-hooks\.setup\]\]/) {
                    nb = 0
                    for (i = 1; i <= np; i++) blk[++nb] = pend[i]
                    np = 0
                    blk[++nb] = line
                    inblock = 1
                    next
                }
                if (line ~ /^[[:space:]]*#/ || line ~ /^[[:space:]]*$/) {
                    pend[++np] = line
                    next
                }
                for (i = 1; i <= np; i++) print pend[i]
                np = 0
                print line
            }
            END {
                if (inblock) {
                    if (!drop) for (i = 1; i <= nb; i++) print blk[i]
                } else {
                    for (i = 1; i <= np; i++) print pend[i]
                }
            }
        ' "$config_path" >$stripped
        or begin
            rm -f $stripped
            echo (set_color red)"✗ failed to rewrite $config_path"(set_color normal)
            return 1
        end
        command cp $stripped "$config_path"
        rm -f $stripped
    end

    mkdir -p (dirname "$config_path")
    if not test -e "$config_path"
        echo '#:schema https://docs.jj-vcs.dev/latest/config-schema.json' >"$config_path"
    end

    printf '%s\n' \
        '' \
        '# Symlink the invocation workspace’s node_modules trees instead of' \
        '# hardlink-copying them. We only use these workspaces for linting, so nothing' \
        '# mutates node_modules — symlinks are instant where `cp -al` was hundreds of' \
        '# thousands of link() syscalls. The shared trees must stay read-only: do NOT run' \
        "# an install in a hook'd workspace, or it will mutate the source workspace's" \
        '# node_modules.' \
        '[[jj-hooks.setup]]' \
        'name = "share node_modules"' \
        "run = [\"$helper\"]" \
        >>"$config_path"

    # Verify jj can still parse the config.
    if not jj config get jj-hooks.setup &>/dev/null
        echo (set_color red)"✗ jj failed to parse $config_path after edit — please review"(set_color normal)
        return 1
    end

    echo (set_color green)"✓ Added 'share node_modules' hook to $config_path"(set_color normal)
end
