# dotfiles

Personal dotfiles for macOS and Debian/Linux (headless) managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap a new machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lancehunt/dotfiles2
```

This will install chezmoi and apply all dotfiles in one step, including setup scripts for mise, Homebrew packages, Vundle, iTerm2 settings, and macOS system preferences.

### Prerequisites

- macOS, or Debian/Ubuntu (headless is fine)
- `curl`

On Linux, packages come from apt (`run_onchange_before_05_apt-packages.sh.tmpl`, asks for sudo only
when something is missing) plus the linux block of `dot_config/mise/config.toml.tmpl` instead of the
Brewfile. macOS-only targets are skipped via `.chezmoiignore`. Deviations and rationale:
[PORTABILITY.md](PORTABILITY.md).

## Day-to-day usage

| Command | Description |
|---|---|
| `chezmoi apply` | Apply changes to `$HOME` |
| `chezmoi add <file>` | Track a new dotfile |
| `chezmoi diff` | Preview pending changes |
| `chezmoi edit <file>` | Edit a managed file |
| `chezmoi edit ~/.macos` | Edit macOS system settings (auto-applies on next `chezmoi apply`) |
| `macos-snapshot` | Snapshot current macOS defaults before making changes in System Settings |
| `macos-diff` | Show what defaults changed since last snapshot |
| `chezmoi re-add` | Re-add all managed files that have changed since last update |
| `chezmoi edit ~/.config/mise/config.toml` | Add a mise tool (the config is a template, so `mise use -g` edits get overwritten on next apply) |
| `brew bundle dump --global --force && chezmoi add ~/.Brewfile` | Update Brewfile from currently installed packages |
