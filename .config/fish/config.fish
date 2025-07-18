## Homebrew paths
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
## Cargo paths
fish_add_path /Users/rwblickhan/.cargo/bin
## pnpm paths
fish_add_path /Users/rwblickhan/.local/bin
fish_add_path ~/utils
fish_add_path ~/bin

source ~/utils/secrets.fish

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

set -gx EDITOR nvim
set -gx LEDGER_FILE ~/Developer/finance/2025.journal

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

if status is-interactive
    if command -sq zoxide
      zoxide init fish --cmd cd | source
    end
    if command -sq starship
      starship init fish | source
    end

    abbr -a exp expense
    abbr -a f rfv
    abbr -a c code
    abbr -a g git
    abbr -a j just
    abbr -a n nvim
    abbr -a p pnpm
    abbr -a z zed

    abbr -a --position anywhere r2b s3:https://d68842214bc7eab6283e7ef8876b12e6.r2.cloudflarestorage.com/backups

    abbr -a bbic "brew bundle install --cleanup --file=~/.config/Brewfile && brew upgrade"
end
