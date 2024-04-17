## Homebrew paths
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
## Cargo paths
fish_add_path /Users/rwblickhan/.cargo/bin
## pnpm paths
fish_add_path /Users/rwblickhan/.local/bin
fish_add_path ~/utils

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

# Aliases
alias cat bat
alias ls "exa --icons"
alias du dust
alias find fd
alias diff delta

if status is-interactive
    zoxide init fish --cmd cd | source
    starship init fish | source

    abbr -a g git
    abbr -a j just
    abbr -a n nvim
    abbr -a p pnpm
    abbr -a px "pnpm exec"
    abbr -a t tmux
    abbr -a tx tmuxinator
    abbr -a f rfv
    abbr -a bbic "brew bundle install --cleanup --file=~/.config/Brewfile --no-lock && brew upgrade"
    abbr -a rlox "tmuxinator start rlox"
    abbr -a rwb "tmuxinator start rwb"
    abbr -a sneak "tmuxinator start sneak"
end
