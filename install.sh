sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/rwblickhan/chezmoi.git
sudo apt install fish -y
# Install jj
curl -L https://github.com/jj-vcs/jj/releases/download/v0.40.0/jj-v0.40.0-aarch64-unknown-linux-musl.tar.gz | tar -xz -C $HOME/.local/bin jj
