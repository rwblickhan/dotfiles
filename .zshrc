export ZSH="$HOME/.oh-my-zsh"

# Set up colored echos
source $HOME/.rainbow.sh

# Check if a command exists
export exists() {
    type $1 &> /dev/null
}

# Alias only if target exists
safealias() {
    local name=$1; shift
    local target=$1

    if exists $target; then
        alias $name="$*"
    fi
}

# Don't set an oh-my-zsh theme
ZSH_THEME=""

# Make - and _ equivalent
HYPHEN_INSENSITIVE="true"

# Update oh-my-zsh automatically
DISABLE_UPDATE_PROMPT="true"

# Disable ls colors because we want to use exa instead
DISABLE_LS_COLORS="true"

plugins=(
  brew
  fzf
  gitfast
  gh
  httpie
  tmux
  tmuxinator
  zoxide
)

export LEDGER_FILE=~/Developer/finance/2023.journal

# Use Neovim as default editor
export EDITOR='nvim'

# Use `fd` by default in `fzf` to hide `.gitignore`'d files
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Show a fancy preview window when using Ctrl+T
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"

# Aliases
safealias 'vim' 'nvim'
safealias 'cat' 'bat'
safealias 'ls' 'exa' '--icons'
safealias 'du' 'dust'
safealias 'find' 'fd'
safealias 'diff' 'delta'
safealias 'j' 'just'

# Show a fancy `fzf`-powered selector with a preview window
alias rgf='f() { rg $1 --files-with-matches | fzf --preview-window=wrap --preview "rg --color=always $1 {}" }; f'

# Use `rgn` to show only file names with `rg`
safealias 'rgn' 'rg' '--files-with-matches'

# Add Homebrew-installed completions 
# https://github.com/casey/just#shell-completion-scripts
eval "$(brew shellenv)"
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Set up oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set up zoxide
if exists zoxide; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# Set up starship theme
if exists starship; then
    eval "$(starship init zsh)"
fi

# Set up Homebrew on M1 Macs
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
