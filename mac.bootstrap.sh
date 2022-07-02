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
brew install neovim
brew install colima

if [ ! -d "/Applications/Raycast.app" ]; then
    brew install --cask raycast
fi

if ! [ -x "$(command -v docker-compose)" ]; then
    if [[ $(uname -m) == "arm64" ]]; then
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-aarch64 -o /usr/local/bin/docker-compose
    else
        sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-darwin-x86_64 -o /usr/local/bin/docker-compose
    fi
    sudo chmod +x /usr/local/bin/docker-compose
fi

colima start
