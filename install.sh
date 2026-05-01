#!/bin/bash
set -euo pipefail

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
"$HOME/.local/bin/chezmoi" init --apply https://github.com/rwblickhan/chezmoi.git

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH for this session and persist to .bashrc (Linux install path)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
printf '\neval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\n' >> "$HOME/.bashrc"

brew tap neurosnap/tap

npm install -g vscode-langservers-extracted

brew install \
    bat \
    fd \
    fish \
    fzf \
    git-delta \
    helix \
    jj \
    typescript-language-server \
    neurosnap/tap/zmx
