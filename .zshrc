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
  docker  
  docker-compose
  gitfast
  swiftpm
  tmux
  vi-mode
  zoxide
  # Order matters! vi-mode tries to overwrite Ctrl+T
  fzf
)

# Use Neovim as default editor
export EDITOR='nvim'

# Use `fd` by default in `fzf` to hide `.gitignore`'d files
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Show a fancy preview window when using Ctrl+T
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"

# Redraw vi-mode prompt when changing mode
export VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
# Change cursor style when changing mode with vi-mode
export VI_MODE_SET_CURSOR=true

# Automatically start tmux when zsh starts
if exists tmux; then
    export ZSH_TMUX_AUTOSTART=true
fi

# Aliases
safealias 'vim' 'nvim'
safealias 'cat' 'bat'
safealias 'ls' 'exa' '--icons'
safealias 'du' 'dust'
safealias 'find' 'fd'
safealias 'diff' 'delta'

# Show a fancy `fzf`-powered selector with a preview window
alias rgf='f() { rg $1 --files-with-matches | fzf --preview-window=wrap --preview "rg --color=always $1 {}" }; f'

# Set up oh-my-zsh
source $ZSH/oh-my-zsh.sh

if exists zoxide; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# Set up starship theme
if exists starship; then
    eval "$(starship init zsh)"
fi
