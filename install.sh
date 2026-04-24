sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/rwblickhan/chezmoi.git
sudo apt install git-delta fd-find bat -y

# Install fish from GitHub releases
FISH_VERSION=$(curl -fsLS https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/')
curl -fsLS "https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}-linux-x86_64.tar.xz" | tar -xJ -C ~/.local/bin

# Install fzf from GitHub releases
FZF_VERSION=$(curl -fsLS https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "v\(.*\)".*/\1/')
rm -f ~/.local/bin/fzf
curl -fsLS "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" | tar -xz -C ~/.local/bin

# Install Helix from GitHub releases
HX_VERSION=$(curl -fsLS https://api.github.com/repos/helix-editor/helix/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/')
HX_TARBALL="helix-${HX_VERSION}-x86_64-linux.tar.xz"
curl -fsLS "https://github.com/helix-editor/helix/releases/download/${HX_VERSION}/${HX_TARBALL}" -o "/tmp/${HX_TARBALL}"
tar -xf "/tmp/${HX_TARBALL}" -C /tmp
mv "/tmp/helix-${HX_VERSION}-x86_64-linux/hx" ~/.local/bin/hx
mkdir -p ~/.config/helix
cp -r "/tmp/helix-${HX_VERSION}-x86_64-linux/runtime" ~/.config/helix/runtime
rm -rf "/tmp/${HX_TARBALL}" "/tmp/helix-${HX_VERSION}-x86_64-linux"

# Aliases
ln -s $(which fdfind) ~/.local/bin/fd
ln -s $(which batcat) ~/.local/bin/bat

# Install jj
curl https://mise.run | sh
~/.local/bin/mise install-into jujutsu@latest /tmp/jj-install
mv /tmp/jj-install/jj ~/.local/bin
rm -rf /tmp/jj-install

# Install zmx
curl -fsLS "https://zmx.sh/a/zmx-0.5.0-linux-x86_64.tar.gz" | tar -xz -C ~/.local/bin

npm i -g typescript-language-server
