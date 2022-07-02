#!/bin/bash
set euxo -pipefail

echo "Running dotbot..."
./dotbot.sh

if [ ! -d "$HOME/.oh-my-zsh" ]
then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh installation not necessary"
fi

if ! [ -x "$(command -v brew)" ]
then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew installation not necessary"
fi

echo "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

echo "Installing command-line tools..."
brew install neovim
brew install ripgrep
brew install exa
brew install bat
brew install git-delta
brew install fd
brew install dust
brew install fzf
brew install procs
brew install zoxide
brew install starship

if [ ! -d "/Applications/Raycast.app" ]
then
    echo "Installing Raycast..."
    brew install --cask raycast
else
    echo "Raycast installation not necessary"
fi

# docker support without docker desktop!
echo "Installing Colima..."
brew install colima

if ! [ -x "$(command -v docker-compose)" ]; then
    if [[ $(uname -m) == "arm64" ]]; then
        echo "Installing docker-compose for M1..."
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-aarch64 -o /usr/local/bin/docker-compose
    else
        echo "Installing docker-compose for Intel..."
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-x86_64 -o /usr/local/bin/docker-compose
    fi
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "docker-compose installation not necessary"
fi

echo "Starting Colima..."
colima start

echo "Remember to restart your terminal to source the new dotfiles!"
