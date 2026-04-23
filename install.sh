sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/rwblickhan/chezmoi.git
sudo apt install fish -y
# Install jj
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo binstall --strategies crate-meta-data jj-cli
