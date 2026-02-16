# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal macOS dotfiles managed with [Chezmoi](https://www.chezmoi.io/). Managed dotfiles live under `chezmoi/` and are applied to `$HOME` via chezmoi's naming conventions (`dot_` prefix becomes `.`, `.tmpl` suffix enables Go templating).

## Key Commands

- **Bootstrap from scratch:** `./install.sh` (downloads chezmoi if needed, runs `chezmoi init --apply`)
- **Apply changes:** `chezmoi apply`
- **Add a dotfile:** `chezmoi add <file>` (pre-hook converts iTerm2 plist to XML1)
- **Preview diff:** `chezmoi diff`
- **Install brew packages:** `brew bundle --file=chezmoi/Brewfile --no-upgrade`
- **Run pre-commit hooks:** `pre-commit run --all-files`

## Architecture

### Chezmoi Script Execution Order

Scripts in `chezmoi/.chezmoiscripts/` run in numbered order:

1. `run_once_before_01_install_mise.sh` — installs mise (tool version manager)
2. `run_onchange_brew-packages.sh.tmpl` — runs `brew bundle` when Brewfile changes (macOS only)
3. `run_once_after_10_mise_install.sh` — installs language versions via mise
4. `run_once_after_setup-system-settings.sh.tmpl` — sets macOS defaults (macOS only)
5. `run_once_after_install-iterm2-settings.sh.tmpl` — configures iTerm2 prefs path

Scripts with `.tmpl` suffix use Go templates for OS-conditional logic (e.g., guarded by `{{ if eq .chezmoi.os "darwin" }}`).

### Shell Configuration Load Order

1. `.zshenv` — Cargo environment
2. `.zprofile` — Homebrew shell env, pyenv shims, OrbStack
3. `.zshrc` — Main config: history, plugins (vim-mode, syntax-highlighting, fzf), completions, tool initialization (nvm, pyenv, conda, mise, atuin, starship, zoxide, thefuck)
4. `.aliases` — Shell aliases (navigation, git, AWS, k8s, system)
5. `.functions` — Utility functions (yaml2json, credential helpers, keychain secret management)
6. `.aws-profile` — AWS CLI helpers, SSO, localstack aliases
7. `.kubectl-profile` — Kubernetes aliases using kubecolor

### Pre-commit Hooks

Configured in `.pre-commit-config.yaml`:
- Standard checks: trailing whitespace, large files, JSON/YAML validation, merge conflicts
- Security: AWS credential detection, private key detection, gitleaks secret scanning

## Conventions

- macOS-only scripts use `.tmpl` extension with darwin guards
- Brewfile manages all packages: taps, brews, casks, VS Code extensions, Mac App Store apps, Go binaries, and Cargo packages
- `chezmoi.toml` defines a pre-add hook that converts iTerm2 plist to XML1 format
- When unsure about chezmoi behavior, templating, or script conventions, refer to the official docs at https://www.chezmoi.io/
