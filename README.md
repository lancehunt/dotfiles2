# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap a new machine

```sh
git clone git@github.com:lancehunt/dotfiles2.git ~/.local/share/chezmoi
~/.local/share/chezmoi/install.sh
```

This will:
1. Install chezmoi if not already present
2. Apply all dotfiles to `$HOME`
3. Run setup scripts (installs mise, Homebrew packages, Vundle, iTerm2 settings, macOS system preferences)

### Prerequisites

- macOS
- `curl` or `wget`
- SSH key with access to GitHub (for the initial clone)

## Day-to-day usage

| Command | Description |
|---|---|
| `chezmoi apply` | Apply changes to `$HOME` |
| `chezmoi add <file>` | Track a new dotfile |
| `chezmoi diff` | Preview pending changes |
| `chezmoi edit <file>` | Edit a managed file |
| `brew bundle --file=chezmoi/Brewfile --no-upgrade` | Install Homebrew packages |
