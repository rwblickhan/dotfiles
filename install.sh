#!/bin/bash

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done

    # Copy .config folder into appropriate place
    cp -r .config ~/.config
}

create_symlinks

echo "Installing command-line tools..."
sudo apt-get update
sudo apt-get install neovim -y
sudo apt-get install ripgrep -y
sudo apt-get install exa -y
sudo apt-get install bat -y
sudo apt-get install fd-find -y
sudo apt-get install fzf -y
sudo apt-get install zoxide -y
sudo apt-get install cargo -y

echo "Installing Powerline fonts..."
sudo apt-get install powerline fonts-powerline -y

echo "Installing starship theme..."
cargo install starship

echo "Installing git-delta..."
cargo install git-delta
