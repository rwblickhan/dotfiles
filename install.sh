#!/bin/bash

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    echo "Symlinking .zshrc..."
    ln -s $script_dir/.zshrc.minimal ~/.zshrc

    echo "Copying starship config..."
    cp $script_dir/.config/starship.toml ~/.config/starship.toml
}

create_symlinks

echo "Installing command-line tools..."
sudo apt-get update
sudo apt-get install neovim -y
sudo apt-get install ripgrep -y
sudo apt-get install fd-find -y
sudo apt-get install fzf -y

echo "Installing Powerline fonts..."
sudo apt-get install powerline fonts-powerline -y

echo "Installing starship theme..."
curl -sS https://starship.rs/install.sh >> starship_install.sh
chmod +x starship_install.sh
./starship_install.sh -y
