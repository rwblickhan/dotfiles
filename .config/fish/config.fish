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

# Editor
set -gx EDITOR nvim

set -gx LEDGER_FILE ~/Developer/finance/2025.journal

# Aliases
alias cat bat
alias ls "eza --icons"
alias du dust
alias find fd
alias diff delta
alias man "BAT_THEME='Monokai Extended' batman"

if status is-interactive
    zoxide init fish --cmd cd | source
    starship init fish | source

    abbr -a c code
    abbr -a f rfv
    abbr -a g git
    abbr -a j just
    abbr -a n nvim
    abbr -a p pnpm
    abbr -a z zed

    abbr -a bbic "brew bundle install --cleanup --file=~/.config/Brewfile && brew upgrade"
    abbr -a --command git br 'branch'
    abbr -a --command git st 'stash'
    abbr -a --command git sts 'stash show -p'
    abbr -a --command git stp 'stash pop'
    abbr -a --command git std 'stash drop'

    abbr -a --command gh pv 'pr view -w'
    abbr -a --command gh ps 'pr status'
    abbr -a --command gh pm 'pr merge'
end
