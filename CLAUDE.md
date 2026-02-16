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

## Conventions

- `.tmpl` suffix = Go templates, macOS-only scripts guard with `{{ if eq .chezmoi.os "darwin" }}`
- Chezmoi scripts in `chezmoi/.chezmoiscripts/` run in numbered order
- Shell config loads: `.zshenv` → `.zprofile` → `.zshrc` → `.aliases` → `.functions` → `.aws-profile` → `.kubectl-profile`
- Brewfile manages all packages (taps, brews, casks, VS Code extensions, MAS apps)
- `chezmoi.toml` pre-add hook converts iTerm2 plist to XML1
- Pre-commit hooks in `.pre-commit-config.yaml` check formatting + scan for secrets
- Refer to https://www.chezmoi.io/ for chezmoi conventions
