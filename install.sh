#!/bin/bash

echo "Running dotbot..."
./dotbot_minimal.sh

echo "Installing command-line tools..."
sudo apt-get update
sudo apt-get install neovim -y
sudo apt-get install ripgrep -y
sudo apt-get install fd-find -y
sudo apt-get install fzf -y
sudo apt-get install git-extras -y

echo "Symlinking fd..."
ln -s $(which fdfind) ~/.local/bin/fd

echo "Symlinking delt..."
ln -s $(which git-delta) ~/.local/bin/delta

echo "Installing Powerline fonts..."
sudo apt-get install powerline fonts-powerline -y

echo "Installing starship theme..."
curl -sS https://starship.rs/install.sh >> starship_install.sh
chmod +x starship_install.sh
./starship_install.sh -y
