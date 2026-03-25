## Homebrew paths
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
## Cargo paths
fish_add_path /Users/rwblickhan/.cargo/bin
## pnpm paths
fish_add_path /Users/rwblickhan/.local/bin
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
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
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

    source ~/utils/fzf-git.sh/fzf-git.fish
    source ~/utils/fzf-jj.sh/fzf-jj.fish

    abbr -a a 'git a'
    abbr -a c code
    abbr -a ch chezmoi
    abbr -a f rfv
    abbr -a g git
    abbr -a h hx
    abbr -a j jj
    abbr -a m mise
    abbr -a n nvim
    abbr -a o open
    abbr -a p pnpm
    abbr --set-cursor -a s 'git commit -m "%" && git push'

    abbr -a nw new_workspace
    abbr -a exp expense
    abbr -a bbic "brew bundle install --cleanup --file=~/Brewfile && brew upgrade"
end
