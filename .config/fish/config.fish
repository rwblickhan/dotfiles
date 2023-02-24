fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /Users/rwblickhan/.cargo/bin

if status is-interactive
    # Set a longer delay for Escape for key combinations
    # Notably, allows using Esc-E to edit the line
    set -g fish_escape_delay_ms 100

    # Use `fd` by default in `fzf` to hide `.gitignore`'d files
    set -U FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -U FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    # Show a fancy preview window when using Ctrl+T
    set -U FZF_CTRL_T_OPTS "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
end

set -U LEDGER_FILE /Users/rwblickhan/Developer/finance/2023.journal
set -U EDITOR nvim

alias cat bat
alias ls "exa --icons"
alias du dust
alias find fd
alias diff delta

abbr -a j just
abbr -a t tmux
abbr -a rgn rg --files-with-matches

starship init fish | source
zoxide init fish --cmd cd | source
