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

echo "Installing neovim..."
brew install neovim

echo "Installing ripgrep..."
brew install ripgrep

echo "Installing exa..."
brew install exa

echo "Installing bat..."
brew install bat

echo "Installing delta..."
brew install git-delta

echo "Installing fd..."
brew install fd

echo "Installing dust..."
brew install dust

echo "Installing fzf..."
brew install fzf

echo "Installing procs..."
brew install procs

echo "Installing zoxide..."
brew install zoxide

echo "Installing pgcli..."
brew tap dbcli/tap
brew install pgcli

echo "Installing HTTPie..."
brew install httpie

echo "Installing tealdeer..."
brew install tealdeer

echo "Installing Github CLI..."
brew install gh

echo "Installing Stork CLI..."
brew install stork-search/stork-tap/stork

echo "Installing starship prompt..."
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

echo "Authenticating with Github..."
gh auth login

echo "Remember to restart your terminal to source the new dotfiles!"

