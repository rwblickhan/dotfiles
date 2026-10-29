#!/bin/bash
set -euo pipefail

# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
"$HOME/.local/bin/chezmoi" init --apply https://github.com/rwblickhan/chezmoi.git

# Install mise and bootstrap tools from ~/.config/mise
curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh
"$HOME/.local/bin/mise" bootstrap --yes

printf '\nexec fish\n' >> "$HOME/.bashrc"
