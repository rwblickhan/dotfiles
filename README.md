# dotfiles

## dotbot

[dotbot](https://github.com/anishathalye/dotbot) is a simple dotfiles manager, installed here as a git submodule.
`dotbot.sh` symlinks `.zshrc` and `dotbot_minimal.sh` symlinks `.zshrc_minimal` instead.

## .zshrc

* Enable [`oh-my-zsh`](https://ohmyz.sh) with quite a few plugins and aliases, mostly for [new command line tools](https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/) - see [my article](https://rwblickhan.org/technical/2022-command-line-tools/) for more details on some of these!
* Turn on `HYPHEN_INSENSITIVE` because I prefer `_` aesthetically but I prefer typing `-`.
* Turn on `DISABLE_UPDATE_PROMPT` to avoid the annoying update prompt on terminal launch.
* Enable a few customizations for [`fzf`](https://github.com/junegunn/fzf), as well as a fancy version of [`rg`](https://github.com/BurntSushi/ripgrep) that uses `fzf` to show a preview window.
* Use the [starship](https://starship.rs) theme, with some customizations (see below).

`.zshrc_minimal` removes a number of the aliases that are less useful for Github Codespaces.

## .gitconfig

* Use [`delta`](https://github.com/dandavison/delta) for `git diff`.
* Use `git b` as an alias for a fancy branch switcher using [`fzf`](https://github.com/junegunn/fzf) (h/t to my Asana colleague Theo Spears!).
* Use `git c` and `git cn` as an alias for diffing, using `fzf` to search branches, with `--name-only` in the latter.
* Use `git l` as an alias for a simpler one-line `git log` output.
* Use `git oops` as an alias to squash current changes with the last commit - useful when you commit and immediately notice a typo!

## .config/starship.toml

Basic configurations for the [starship](https://starship.rs) prompt.

* Disable the extra newline between every command prompt.
* Disable the command timer, which is particularly useless for neovim sessions.
* Disable many of the language version prompts.

## .config/nvim/init.vim

* Install various plugins:
  * Install the Palenight theme.
  * Install various LSP helpers, including Trouble (a prettier error menu) and `null-ls` (hook non-LSP sources like markdownlint into Neovim's LSP implementation).
  * Install the Terraform plugin.
* Navigate around visual lines instead of logical ones.
* Turn tabs into spaces.
* Set :Format and \f as aliases for LSP formatting.

## mac_bootstrap.sh

* Install and run `dotbot` to symlink dotfiles.
* Install `oh-my-zsh`.
* Install Homebrew.
* Install Terraform.
* Install various command-line tools.
* Install Colima and docker-compose and start Colima.
* Install Raycast.

## install.sh

Intended to bootstrap basic Ubuntu boxes, like for Github Codespaces.

* Install and run `dotbot` to symlink dotfiles.
* Install various command-line tools.
* Symlink `fdfind` to `fd`, because the `fd` binary is named differently on Ubuntu.
* Install Powerline fonts.
* Install the starship prompt theme.
