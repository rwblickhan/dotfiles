sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin
chezmoi init --apply https://github.com/rwblickhan/chezmoi.git
sudo apt install fish
sudo apt install jj
