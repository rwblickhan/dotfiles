#!/usr/bin/env bash
cp -r .config/* ~/.config
cp .gitconfig ~/.gitconfig
touch ~/utils/secrets.fish
cargo install git-delta
