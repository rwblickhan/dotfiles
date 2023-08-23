#!/bin/zsh

source utils/rainbow.sh

echogreen "Running dotbot..."
./dotbot.sh

if ! [ -x "$(command -v brew)" ]; then
    echogreen "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echogreen "Homebrew is already installed!"
fi

brew bundle install --cleanup --file=~/.config/Brewfile --no-lock && brew upgrade

echogreen "Log in to Github? (y/n)"
read answer

if [ answer = "y" ]; then
    echogreen "Authenticating with Github..."
    gh auth login
else
    echogreen "Skipping Github authentication!"
fi

echogreen "Remember to restart your terminal to source the new dotfiles!"

