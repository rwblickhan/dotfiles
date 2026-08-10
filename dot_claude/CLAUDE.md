# CLAUDE.md

## Style

Don't write comments, unless it's necessary to match existing code (e.g. docstrings on a function in an file where every other function has docstrings).
Assume I and the code reviewers understand your code unless I explicitly ask you write comments or explain something.

## Version Control

I use jj (jujutsu) for version control. In a directory where both jj and git are active, use jj unless I specify otherwise.

I often use jj workspaces. If you're currently in a jj workspace, assume you're in the current workspace and do NOT make changes in the root workspace.

## Shell

I use fish shell. Assume I want fish functions and fish-compatible shell scripts unless I specify otherwise.

## Config

I use chezmoi to manage my dotfiles. If asked to update configuration that might be stored in chezmoi, check chezmoi and make changes there first.
