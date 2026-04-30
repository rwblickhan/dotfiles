fish_add_path ~/.local/bin
fish_add_path /workspaces/obsidian/node_modules/.bin
## Homebrew paths
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
## Cargo paths
fish_add_path ~/.cargo/bin
## pnpm paths
fish_add_path ~/utils
fish_add_path ~/bin

set -gx MANPATH $MANPATH ~/man

# pnpm variables
set -gx PNPM_HOME /Users/rwblickhan/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH

# fzf variables
# Bind Ctrl-T to toggle-all
set -gx FZF_DEFAULT_OPTS '--bind ctrl-t:toggle-all'
# Use `fd` by default in `fzf` to hide `.gitignore`'d files
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git . $dir'
# Show a fancy preview window when using Ctrl+T
set -gx FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}'"

set -gx EDITOR hx
set -gx LEDGER_FILE ~/Developer/finance/2026.journal

if command -sq bat
    alias cat bat
end
if command -sq eza
    alias ls "eza --icons"
end
if command -sq delta
    alias diff delta
end
if command -sq batman
    alias man "BAT_THEME='Monokai Extended' batman"
end

set -g fish_transient_prompt 1

if status is-interactive
    if command -sq zoxide
        zoxide init fish --cmd cd | source
    end
    if command -sq mise
        mise activate fish | source
    end
    if command -sq fzf
        fzf --fish | source
    end

    source ~/utils/fzf-git.sh/fzf-git.fish
    source ~/utils/fzf-jj.sh/fzf-jj.fish
    source ~/.config/fish/abbr.fish

    abbr -a c code
    abbr -a ch chezmoi
    abbr -a f rfv
    abbr -a g git
    abbr -a h hx
    abbr -a j jj
    abbr -a m mise
    abbr -a o open
    abbr -a p pnpm
    abbr -a r 'mise run'
    abbr -a z zmx
    abbr --set-cursor -a s 'git commit -m "%" && git push'

    abbr -a nw new_workspace
    abbr -a exp expense
    abbr -a bbic "brew bundle install --cleanup --file=~/Brewfile && brew upgrade"

    abbr_subcommand gh pc "pr create -w"
    abbr_subcommand gh pm "pr merge"
    abbr_subcommand gh ps "pr status"
    abbr_subcommand gh pv "pr view -w"

    abbr_subcommand jj dm "desc -m"
    abbr_subcommand jj e edit
    abbr_subcommand jj l log
    abbr_subcommand jj lb "log -r 'bookmarks()'"
    abbr_subcommand jj p "git push"

    abbr_subcommand g b branch
    abbr_subcommand g c switch
    abbr_subcommand g cb "checkout -b"
    abbr_subcommand g cm "switch main"
    abbr_subcommand g d "diff --ignore-all-space"
    abbr_subcommand g ds "diff HEAD --ignore-all-space"
    abbr_subcommand g dm "diff main --ignore-all-space"
    abbr_subcommand g m "merge --no-edit"
    abbr_subcommand g ma "merge --abort"
    abbr_subcommand g mc "merge --continue"
    abbr_subcommand g mm "merge main --no-edit"
    abbr_subcommand g mt mergetool
    abbr_subcommand g s status
    abbr_subcommand g st stash
end
