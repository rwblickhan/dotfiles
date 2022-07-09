#!/bin/bash

echo "Running dotbot..."
./dotbot.sh

echo "Installing command-line tools..."
sudo apt-get update
sudo apt-get install neovim -y
sudo apt-get install ripgrep -y
sudo apt-get install fd-find -y
sudo apt-get install fzf -y
sudo apt-get install exa -y

echo "Symlinking fd..."
ln -s $(which fdfind) ~/.local/bin/fd

echo "Symlinking bat..."
ln -s $(which batcat) ~/.local/bin/bat

echo "Symlinking zoxide..."
ln -s $(which zoxide) ~/.local/bin/z

echo "Installing Powerline fonts..."
sudo apt-get install powerline fonts-powerline -y

echo "Installing starship theme..."
curl -sS https://starship.rs/install.sh >> starship_install.sh
chmod +x starship_install.sh
./starship_install.sh -y

echo "Installing git-delta..."
tar -xzvf delta-0.13.0-x86_64-unknown-linux-musl.tar.gz
cp delta-0.13.0-x86_64-unknown-linux-musl/delta ~/.local/bin/delta
chmod +x ~/.local/bin/delta
