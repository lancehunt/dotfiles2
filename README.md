# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lancehunt/dotfiles2
```

This will install chezmoi and apply all dotfiles in one step, including setup scripts for mise, Homebrew packages, Vundle, iTerm2 settings, and macOS system preferences.

### Prerequisites

- macOS
- `curl`

## Day-to-day usage

| Command | Description |
|---|---|
| `chezmoi apply` | Apply changes to `$HOME` |
| `chezmoi add <file>` | Track a new dotfile |
| `chezmoi diff` | Preview pending changes |
| `chezmoi edit <file>` | Edit a managed file |
| `chezmoi re-add` | Re-add all managed files that have changed since last update |
| `mise use -g npm:{package}@latest` | Install a global npm package via mise (tracked by this repo) |
| `brew bundle dump --global --force && chezmoi add ~/.Brewfile` | Update Brewfile from currently installed packages |
