#!/bin/bash

source rainbow.sh

echogreen "Running dotbot..."
./dotbot.sh

echogreen "Installing command-line tools..."
sudo apt-get update
echogreen "Installing exa..."
sudo apt-get install exa -y
echogreen "Installing fd..."
sudo apt-get install fd-find -y
echogreen "Installing fzf..."
sudo apt-get install fzf -y
echogreen "Installing hledger..."
sudo apt-get install hledger -y
echogreen "Installing neovim..."
sudo apt-get install neovim -y
echogreen "Installing npm..."
sudo apt-get install npm -y
echogreen "Installing Node..."
sudo apt-get install nodejs -y
echogreen "Installing rg..."
sudo apt-get install ripgrep -y
echogreen "Installing tmux..."
sudo apt-get install tmux -y
echogreen "Install zsh..."
sudo apt-get install zsh -y
echogreen "Installing zoxide..."
sudo apt-get install zoxide -y

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ ! -d ~/.local/bin ]; then
    echogreen "Touching ~/.local/bin..."
    mkdir ~/.local/bin
fi

echogreen "Sylinking fd..."
ln -s "$(which fdfind)" ~/.local/bin/fd

echogreen "Symlinking bat..."
ln -s "$(which batcat)" ~/.local/bin/bat

echogreen "Symlinking zoxide..."
ln -s "$(which zoxide)" ~/.local/bin/z

echogreen "Installing Powerline fonts..."
sudo apt-get install powerline fonts-powerline -y

echogreen "Installing starship theme..."
curl -sS https://starship.rs/install.sh >> starship_install.sh
chmod +x starship_install.sh
./starship_install.sh -y

echogreen "Installing git-delta..."
tar -xzvf delta-0.13.0-x86_64-unknown-linux-musl.tar.gz
cp delta-0.13.0-x86_64-unknown-linux-musl/delta ~/.local/bin/delta
chmod +x ~/.local/bin/delta
