#!/bin/bash
set euxo -pipefail

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if ! [ -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Favorite command-line tools
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

if [ ! -d "/Applications/Raycast.app" ]; then
    brew install --cask raycast
fi

# docker support without docker desktop!
brew install colima

if ! [ -x "$(command -v docker-compose)" ]; then
    if [[ $(uname -m) == "arm64" ]]; then
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-aarch64 -o /usr/local/bin/docker-compose
    else
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-x86_64 -o /usr/local/bin/docker-compose
    fi
    sudo chmod +x /usr/local/bin/docker-compose
fi

colima start
