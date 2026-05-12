#!/bin/bash
set -euo pipefail

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
"$HOME/.local/bin/chezmoi" init --apply https://github.com/rwblickhan/chezmoi.git

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH for this session only
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
printf '\nexec fish\n' >> "$HOME/.bashrc"
printf '\n# Fix Zed remote extension permissions (root-owned .tmp dirs block extension install)\nfind ~/.local/share/zed/remote_extensions -user root -exec sudo chown -R vscode:vscode {} + 2>/dev/null\n' >> "$HOME/.bashrc"

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

# Symlink all brew-installed binaries to ~/.local/bin so brew doesn't need to be on PATH
for bin in /home/linuxbrew/.linuxbrew/bin/*; do
    ln -sf "$bin" "$HOME/.local/bin/$(basename "$bin")"
done
