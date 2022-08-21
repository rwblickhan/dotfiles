#!/bin/zsh

source rainbow.sh

echogreen "Running dotbot..."
./dotbot.sh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echogreen "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echogreen "oh-my-zsh is already installed!"
fi

if ! [ -x "$(command -v brew)" ]; then
    echogreen "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echogreen "Homebrew is already installed!"
fi

echogreen "Installing bat (better cat)..."
brew install bat

echogreen "Installing Colima (Docker without Docker Desktop)..."
brew install colima

echogreen "Installing Docker..."
brew install docker

echogreen "Installing docker-slim (Docker linter)..."
brew install docker-slim

echogreen "Installing dust (better du)..."
brew install dust

echogreen "Installing exa (better ls)..."
brew install exa

echogreen "Installing fd (better find)..."
brew install fd

echogreen "Installing flake8 (Python linter)..."
brew install flake8

echogreen "Installing Fira Code and Fira Mono Nerd Fonts..."
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-fira-mono-nerd-font

echogreen "Installing fzf (fuzzy finder)..."
brew install fzf

echogreen "Installing Github CLI..."
brew install gh

echogreen "Installing delta (git diff viewer)..."
brew install git-delta

echogreen "Installing hadolint (Dockerfile linter)..."
brew install hadolint

echogreen "Installing hledger (plain-text accounting)..."
brew install hledger

echogreen "Installing HTTPie (better curl)..."
brew install httpie

echogreen "Installing mdlint (Markdown linter)..."
brew install markdownlint-cli

echogreen "Installing Mint (Swift CLI tool package manager)..."
brew install mint

echogreen "Installing neovim (better vim)..."
brew install neovim

echogreen "Installing node..."
brew install node

echogreen "Installing just (command runner)..."
brew install just

echogreen "Installing pgcli (better Postgres CLI)..."
brew tap dbcli/tap
brew install pgcli

echogreen "Installing Pulumi (Infrastructure-as-Code tool)..."
brew tap pulumi/tap
brew install pulumi/tap/pulumi

echogreen "Installing ripgrep (better grep)..."
brew install ripgrep

echogreen "Installing shellcheck (shell script linter)..."
brew install shellcheck

echogreen "Installing starship command prompt..."
brew install starship

echogreen "Installing Stork CLI..."
brew tap stork-search/stork-tap
brew install stork-search/stork-tap/stork

echogreen "Installing tealdeer (tldr client)..."
brew install tealdeer

echogreen "Installing tig (git repo viewer)..."
brew install tig

echogreen "Installing tmux (teminal multiplexer)..."
brew install tmux

echogreen "Installing yamllint (YAML linter)..."
brew install yamllint

echogreen "Installing zoxide (better cd)..."
brew install zoxide

if [ ! -d "/Applications/Raycast.app" ]
then
    echogreen "Installing Raycast (better Spotlight)..."
    brew install --cask raycast
else
    echogreen "Raycast is already installed!"
fi

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
    echogreen "docker-compose is already installed!"
fi

echogreen "Starting Colima..."
colima start

echogreen "Log in to Github? (y/n)"
read answer

if [ answer = "y" ]; then
    echogreen "Authenticating with Github..."
    gh auth login
else
    echogreen "Skipping Github authentication!"
fi

echogreen "Remember to restart your terminal to source the new dotfiles!"

