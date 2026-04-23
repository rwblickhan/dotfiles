sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/rwblickhan/chezmoi.git
sudo apt install fish git-delta fd-find -y

# Install Helix from GitHub releases
HX_VERSION=$(curl -fsLS https://api.github.com/repos/helix-editor/helix/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/')
HX_TARBALL="helix-${HX_VERSION}-x86_64-linux.tar.xz"
curl -fsLS "https://github.com/helix-editor/helix/releases/download/${HX_VERSION}/${HX_TARBALL}" -o "/tmp/${HX_TARBALL}"
tar -xf "/tmp/${HX_TARBALL}" -C /tmp
mv "/tmp/helix-${HX_VERSION}-x86_64-linux/hx" ~/.local/bin/hx
mkdir -p ~/.config/helix
cp -r "/tmp/helix-${HX_VERSION}-x86_64-linux/runtime" ~/.config/helix/runtime
rm -rf "/tmp/${HX_TARBALL}" "/tmp/helix-${HX_VERSION}-x86_64-linux"

# Alias fdfind to fd
ln -s $(which fdfind) ~/.local/bin/fd

# Install jj
curl https://mise.run | sh
~/.local/bin/mise install-into jujutsu@latest /tmp/jj-install
mv /tmp/jj-install/jj ~/.local/bin
rm -rf /tmp/jj-install
