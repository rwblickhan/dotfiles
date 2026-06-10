function setup_jj_hooks --description 'Add a jj-hooks setup hook that symlinks node_modules from the invocation workspace'
    argparse h/help f/force -- $argv
    or return 1

    if set -q _flag_help
        echo "setup_jj_hooks - add a jj-hooks setup hook to the current repo's jj config"
        echo ""
        echo "Adds a [[jj-hooks.setup]] hook that symlinks node_modules from the invocation"
        echo "workspace (\$JJ_HOOKS_WORKSPACE) into each newly created workspace, instead of"
        echo "hardlink-copying it. Instant vs. hundreds of thousands of link() syscalls."
        echo ""
        echo "The shared tree is READ-ONLY: never run an install in a hook'd workspace, or"
        echo "it will mutate the source workspace's node_modules. Intended for lint-only"
        echo "workspaces."
        echo ""
        echo "Usage:"
        echo "  setup_jj_hooks [options]"
        echo ""
        echo "Options:"
        echo "  -f, --force   Re-add the hook even if one named 'share node_modules' exists"
        echo "  -h, --help    Show this help"
        echo ""
        echo "Run from inside the target jj repo. Writes to \`jj config path --repo\`."
        return 0
    end

    if not command -v jj &>/dev/null
        echo (set_color red)"Error: jj is not installed"(set_color normal)
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

    # Idempotency: skip if the hook is already present unless --force.
    if not set -q _flag_force
        if jj config get jj-hooks.setup 2>/dev/null | string match -q '*share node_modules*'
            echo (set_color yellow)"⊘ Hook 'share node_modules' already present in $config_path"(set_color normal)
            return 0
        end
    end

    mkdir -p (dirname "$config_path")
    if not test -e "$config_path"
        echo '#:schema https://docs.jj-vcs.dev/latest/config-schema.json' >"$config_path"
    end

    printf '%s\n' \
        '' \
        '# Symlink node_modules from the invocation workspace instead of hardlink-copying' \
        '# it. We only use these workspaces for linting, so nothing mutates node_modules —' \
        '# a single symlink is instant where `cp -al` was hundreds of thousands of link()' \
        '# syscalls. The shared tree must stay read-only: do NOT run an install in a' \
        "# hook'd workspace, or it will mutate the source workspace's node_modules." \
        '[[jj-hooks.setup]]' \
        'name = "share node_modules"' \
        'run = ["bash", "-c", "ln -sfn \"$JJ_HOOKS_WORKSPACE/node_modules\" node_modules"]' \
        >>"$config_path"

    # Verify jj can still parse the config.
    if not jj config get jj-hooks.setup &>/dev/null
        echo (set_color red)"✗ jj failed to parse $config_path after edit — please review"(set_color normal)
        return 1
    end

    echo (set_color green)"✓ Added 'share node_modules' hook to $config_path"(set_color normal)
end
