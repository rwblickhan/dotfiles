# dotfiles

## dotbot

[dotbot](https://github.com/anishathalye/dotbot) is a simple dotfiles manager, installed here as a git submodule.
`dotbot.sh` symlinks `.zshrc` and `dotbot_minimal.sh` symlinks `.zshrc_minimal` instead.

## .zshrc

* Enable [`oh-my-zsh`](https://ohmyz.sh) with a few plugins and aliases, mostly for [new command line tools](https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/).
  * See [my article](https://rwblickhan.org/technical/2022-command-line-tools/) for more details on some of these!
* Add an `exists` function to check if a command exists and `safealias` to only alias if `exists` is true; that lets me avoid e.g. setting `cd` as an alias for zoxide if zoxide failed to install for whatever reason.
* Turn on `HYPHEN_INSENSITIVE` because I prefer `_` aesthetically but I prefer typing `-`.
* Turn on `DISABLE_UPDATE_PROMPT` to avoid the annoying update prompt on terminal launch.
* Set the default [Ledger](https://hledger.org/1.28/hledger.html) file.
* Set the default editor to [Neovim](https://neovim.io).
* Use [`fd`](https://github.com/sharkdp/fd) as the default for file search in `fzf` to hide `.gitignore`'d files.
* Enable a fancy preview window for `fzf`'s Ctrl-T finder.
* Add two `rg` aliases:
  * `rgn` for "`rg` with **n**ames", appending the `--files-with-matches` flag.
  * `rgf` for an `rg`/`fzf`-powered file search.
* Help zsh find Homebrew-installed shell completions.
* Use the [starship](https://starship.rs) theme, with some customizations (see below).

## .gitconfig

* Use [`delta`](https://github.com/dandavison/delta) for `git diff`.
* `git l` as an alias for a simpler one-line `git log` output.
* `git cam` as an alias for `git commit -a -m`.
* `git p` as an alias for `git push`.
* `git oops` as an alias to squash current changes with the last commit - useful when you commit and immediately notice a typo!
* A bunch of branch-management utilities using [`fzf`](https://github.com/junegunn/fzf) (h/t to my Asana colleague Theo Spears!):
  * `git b` as an alias for switch **b**ranch.
  * `git m` as an alias for **m**erge from another branch.
  * `git c` as an alias for **c**hanges compared to another branch, as well as `git cn` to append `--name-only`.
  * `git d` as an alias for **d**elete branch.
  * `git lf` as an alias for **l**og **f**ind - fuzzy-find `git log` and select the commit message!

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
