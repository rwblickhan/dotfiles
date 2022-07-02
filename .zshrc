export ZSH="/Users/rwblickhan/.oh-my-zsh"

# Don't set an oh-my-zsh theme
ZSH_THEME=""

# Make - and _ equivalent
HYPHEN_INSENSITIVE="true"

# Update oh-my-zsh automatically
DISABLE_UPDATE_PROMPT="true"

plugins=(
  brew
  docker  
  docker-compose
  gitfast
  swiftpm
  terraform
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

# Aliases
alias dev='cd ~/Developer'
alias vim='nvim'
alias cat='bat'
alias ls='exa --icons'
alias du='dust'
alias find='fd'
alias diff='delta'
alias cd='z'
alias cdi='zi'
alias ps='procs'
# Show a fancy `fzf`-powered selector with a preview window
alias rgf='f() { rg $1 --files-with-matches | fzf --preview-window=wrap --preview "rg --color=always $1 {}" }; f'

source $ZSH/oh-my-zsh.sh

# starship theme setup
eval "$(starship init zsh)"
