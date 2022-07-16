#!/bin/zsh

source rainbow.sh

echogreen "Running dotbot..."
./dotbot.sh

if [ ! -d "$HOME/.oh-my-zsh" ]
then
    echogreen "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echogreen "oh-my-zsh installation not necessary"
fi

if ! [ -x "$(command -v brew)" ]
then
    echogreen "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echogreen "Homebrew installation not necessary"
fi

echogreen "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

echogreen "Installing neovim..."
brew install neovim

echogreen "Installing ripgrep..."
brew install ripgrep

echogreen "Installing exa..."
brew install exa

echogreen "Installing bat..."
brew install bat

echogreen "Installing delta..."
brew install git-delta

echogreen "Installing fd..."
brew install fd

echogreen "Installing dust..."
brew install dust

echogreen "Installing fzf..."
brew install fzf

echogreen "Installing procs..."
brew install procs

echogreen "Installing zoxide..."
brew install zoxide

echogreen "Installing pgcli..."
brew tap dbcli/tap
brew install pgcli

echogreen "Installing HTTPie..."
brew install httpie

echogreen "Installing tealdeer..."
brew install tealdeer

echogreen "Installing Github CLI..."
brew install gh

echogreen "Installing just..."
brew install just

echogreen "Installing tmux..."
brew install tmux

echogreen "Installing Stork CLI..."
brew install stork-search/stork-tap/stork

echogreen "Installing starship prompt..."
brew install starship


if [ ! -d "/Applications/Raycast.app" ]
then
    echogreen "Installing Raycast..."
    brew install --cask raycast
else
    echogreen "Raycast installation not necessary"
fi

# docker support without docker desktop!
echogreen "Installing Colima..."
brew install colima

if ! [ -x "$(command -v docker-compose)" ]; then
    if [[ $(uname -m) == "arm64" ]]; then
        echogreen "Installing docker-compose for M1..."
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-aarch64 -o /usr/local/bin/docker-compose
    else
        echogreen "Installing docker-compose for Intel..."
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-x86_64 -o /usr/local/bin/docker-compose
    fi
    sudo chmod +x /usr/local/bin/docker-compose
else
    echogreen "docker-compose installation not necessary"
fi

echogreen "Starting Colima..."
colima start

echogreen "Log in to Github? (y/n)"
read answer

if [ answer = "y" ]; then
    echogreen "Authenticating with Github..."
    gh auth login
else
    echogreen "Skipping authentication!"
fi

echogreen "Remember to restart your terminal to source the new dotfiles!"

