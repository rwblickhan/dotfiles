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

if status is-interactive
    # Use `fd` by default in `fzf` to hide `.gitignore`'d files
    set -U FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -U FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    # Show a fancy preview window when using Ctrl+T
    set -U FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}'"

    zoxide init fish --cmd cd | source
    starship init fish | source

    abbr -a g git
    abbr -a j just
    abbr -a t tmux
    abbr -a tx tmuxinator
    abbr -a f rfv
    abbr -a gsp "git stash pop"
    abbr -a gps "gh pr status"
    abbr -a gpm "gh pr merge"
    abbr -a gpv "gh pr view -w"
    abbr -a bbic "brew bundle install --cleanup --file=~/.config/Brewfile --no-lock && brew upgrade"
    abbr -a rlox "tmuxinator start rlox"
    abbr -a astro "tmuxinator start astro"
    abbr -a sneak "tmuxinator start sneak"
end

set -U EDITOR nvim

alias cat bat
alias ls "exa --icons"
alias lm "exa -l -s modified --no-permissions --icons --no-user --git"
alias du dust
alias find fd
alias diff delta
