## Version Control

I use both jj (jujutsu) and git for version control. In a directory where both jj and git are active, prefer using jj.

## Shell

I use fish shell. Unless I specify otherwise, assume I want fish functions and fish-compatible shell scripts.

## General Project Setup

I use mise for general project setup. For any project built from scratch or starting from a template (like the output of `bun init` or `cargo init`), always add a `mise.toml` with basic project workflows.

## Command-Line Tool Usage

- Prefer rg (ripgrep) instead of grep.
- Prefer sd instead of sed.

## When Building Command-Line Tools

- Always include a comprehensive `--help` option.
- Include a Mise task to build the project and install it as a single-file executable into `~/.local/bin`.
- When possible, include Mise tasks to generate and install manfiles and fish shell completions.
  - Manfiles should be installed into `~/man/man1` and fish completions should be installed into `~/.config/fish/completions`.
  - For instance, in a Rust project, I would expect to see usage of the `clap`, `clap_mangen`, and `clap_complete` crates to generate these.
