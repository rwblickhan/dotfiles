# dotfiles

## dotbot

[dotbot](https://github.com/anishathalye/dotbot) is a simple dotfiles manager, installed here as a git submodule.
Running `.dotbt.sh` installs everything as symlinks.

## .zshrc

Set up zsh and [`oh-my-zsh`](https://ohmyz.sh).

## rainbow.sh

A simple script that adds colored `echo`s like `echogreen`.

## mac_bootstrap.sh

Set up a new Mac from scratch. Basically a bunch of Homebrew-ing and sourcing.

## .gitconfig

Global git configuration:

- Use [`delta`](https://github.com/dandavison/delta) for `git diff`.
- `git l` as an alias for a simpler one-line `git log` output.
- `git cam` as an alias for `git commit -a -m`.
- `git p` as an alias for `git push`.
- `git oops` as an alias to squash current changes with the last commit - useful when you commit and immediately notice a typo!
- A bunch of branch-management utilities using [`fzf`](https://github.com/junegunn/fzf) (h/t to my Asana colleague Theo Spears!):
  - `git b` as an alias for switch **b**ranch.
  - `git m` as an alias for **m**erge from another branch.
  - `git c` as an alias for **c**hanges compared to another branch, as well as `git cn` to append `--name-only`.
  - `git d` as an alias for **d**elete branch.
  - `git lf` as an alias for **l**og **f**ind - fuzzy-find `git log` and select the commit message!

## .config/starship.toml

Basic configurations for the [starship](https://starship.rs) prompt:

- Disable the extra newline between every command prompt.
- Disable the command timer, which is particularly useless for neovim sessions.
- Disable many of the language version prompts.

## .config/nvim/init.vim

Set up [neovim](https://neovim.io).

## .config/cheat/conf.yml

Set up [cheat](https://github.com/cheat/cheat).

- Notably, `.config/cheat/cheatsheets/personal` contains my personal cheatsheets.

## settings.json

Set up [Visual Studio Code](https://code.visualstudio.com), though not its extensions.
I also sync this through VS Code's Settings Sync.

## .tmux.conf

Set up tmux.

## .markdownlintrc

Set up global [markdownlint](https://github.com/markdownlint/markdownlint) rules.

- Notably, disable line length warnings, because I almost never care.

## yamllint/config

Set up global [yamllint](https://github.com/adrienverge/yamllint) rules.

- Notably, disable line length warnings, because I almost never care.

## .inputrc

Disable annoying bell-rings in anything supporting [readline](https://tiswww.case.edu/php/chet/readline/rltop.html).
