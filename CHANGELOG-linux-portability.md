# Changelog: linux-portability (append-only)
Format: `YYYY-MM-DD HH:MM | host-type | file(s) | what changed and why | commit`
Entries up to 01:56 were backfilled from the session (times approximate).

2026-11-14 01:30 | debian | ~/.config/mise/config.toml, ~/.local/share/mise | `mise use -g chezmoi@latest` to get chezmoi (not in apt) | n/a (host state)
2026-11-14 01:30 | all | ~/.local/share/chezmoi | cloned lancehunt/dotfiles2 as chezmoi source; created local branch linux-portability | n/a
2026-11-14 01:31 | all | dot_config/mise/config.toml -> .tmpl | linux-only block: tools missing/stale in apt (go, gh, gitleaks, k9s, sops, ... go:/cargo:/pipx: entries); darwin render unchanged | 6a38dd1
2026-11-14 01:32 | debian | .chezmoiscripts/run_onchange_before_05_apt-packages.sh.tmpl | first apt package script (later replaced, see 01:52) | 6a38dd1 (superseded)
2026-11-14 01:33 | darwin | .chezmoiscripts/run_once_after_install-iterm2-settings.sh.tmpl | bug fix: wrap in darwin guard (ran `defaults write` on any OS) | 6a38dd1
2026-11-14 01:33 | all | chezmoi/.chezmoiignore (new) | ignore .Brewfile, .macos, .config/iterm2, Library/, macos-diff/snapshot, update-claude-credentials on non-darwin | 6a38dd1
2026-11-14 01:34 | all | run_once_before_01_install_mise.sh | skip curl|sh if ~/.local/bin/mise exists | 6a38dd1
2026-11-14 01:34 | all | run_once_after_10_mise_install.sh -> run_onchange_after_10_mise_install.sh.tmpl | re-run mise install when mise config template changes | 6a38dd1
2026-11-14 01:35 | all | dot_zshrc | command -v guards (atuin, pyenv, thefuck, mise, go, code); conda only if ~/miniconda3; Rancher + /opt/homebrew PATHs darwin-only; assume alias via PATH; ulimit quiet | 6a38dd1
2026-11-14 01:35 | all | dot_zprofile | pyenv shim block only if pyenv exists | 6a38dd1
2026-11-14 01:36 | all | dot_aliases | darwin guards for macOS-only aliases; Linux equivalents (update, myip, localip, ips, flush, httpdump, OSC52 pbcopy, age-backed secret-*); bat/moor/ctags guards; urlencode -> python3 | 6a38dd1
2026-11-14 01:37 | all | dot_kubectl-profile | kubectl completion only if kubectl exists; `complete -F` only if defined | 6a38dd1
2026-11-14 01:37 | all | dot_gitconfig -> .tmpl | templatedir from homeDir; gh credential helper path per OS | 6a38dd1
2026-11-14 01:37 | debian | dot_zshenv | Linux: prepend ~/.local/bin + mise shims (zsh skips ~/.profile; mirrors ~/.bashrc line 1) | 6a38dd1
2026-11-14 01:38 | debian | ~/.config/mise/config.toml.pre-chezmoi.bak | backup of pre-existing mise config (node 22) before apply | n/a
2026-11-14 01:38 | debian | ~ (dotfiles) | `chezmoi apply --exclude=scripts` (umask 022): .aliases .aws-profile .functions .gitconfig .global_gitattributes .kubectl-profile .vimrc .zprofile .zshenv .zshrc, mise config, ~/.local/bin/{claude-mode,git-update-all} | n/a
2026-11-14 01:38 | debian | ~/.local/share/mise/installs | `mise install`: 59 tools | n/a
2026-11-14 01:39 | debian | ~/.local/share/zsh/plugins | znap + 4 plugins cloned by first test zsh start | n/a
2026-11-14 01:40 | all | dot_zshrc | `stty stop undef` only on a TTY | 6a38dd1
2026-11-14 01:40 | all | dot_gitconfig.tmpl | templatedir only if ~/.git-templates exists (git warned on every clone) | 6a38dd1
2026-11-14 01:42 | all | PORTABILITY.md (new) | deviation notes | 6a38dd1
2026-11-14 01:44 | debian | dot_config/mise/config.toml.tmpl | removed go:gorename (resolves to deprecated stub) | 6a38dd1
2026-11-14 01:45 | debian | dot_config/mise/config.toml.tmpl | cargo:kondo -> github:tbillington/kondo (cargo build needs a C linker, not installed) | 6a38dd1
2026-11-14 01:46 | debian | dot_config/mise/config.toml.tmpl | removed go:github.com/lancehunt/ideas (private repo, no creds; broke mise install) | 6a38dd1
2026-11-14 01:46 | all | dot_aliases | urlencode moved out of darwin block (was swallowed by guard) | 6a38dd1
2026-11-14 01:47 | all | README.md, CLAUDE.md | document dual-OS setup | 6a38dd1
2026-11-14 01:48 | debian | ~/NOTE-to-observer.md | first reply to observer | n/a
2026-11-14 01:49 | all | chezmoi/.chezmoi.toml.tmpl (new) | host data headless/pkgmgr; darwin plutil pre-add hook moved here | 6a38dd1
2026-11-14 01:49 | debian | ~/.config/chezmoi/chezmoi.toml | generated via `chezmoi init` | n/a
2026-11-14 01:50 | debian | .chezmoiscripts/run_before_05_os-packages.sh.tmpl (replaces run_onchange_before_05_apt-packages) | keyed on .pkgmgr; run every apply; sudo only if `sudo -n true`, else print `sudo -v && chezmoi apply`; bat/fd symlinks; chsh; git-gui only if !headless; message on unknown distro | 6a38dd1
2026-11-14 01:50 | all | run_once_after_20_install_vundle.sh -> .tmpl | render only if vim exists (don't spend run_once before vim installed); darwin bytes identical | 6a38dd1
2026-11-14 01:51 | all | chezmoi/.chezmoi.toml.tmpl | umask = 0o022 (modes independent of caller umask) | 6a38dd1
2026-11-14 01:51 | debian | ~ | `chezmoi init` + full `chezmoi apply` (scripts included) x2: exit 0, idempotent | n/a
2026-11-14 01:52 | debian | run_before_05_os-packages.sh.tmpl | post-check: non-interactive zsh must find mise+claude (observer suggestion) | 6a38dd1
2026-11-14 01:52 | all | PORTABILITY.md, CLAUDE.md | host-types section, verification, follow-ups | 6a38dd1
2026-11-14 01:52 | all | git | commit 6a38dd1 on linux-portability (local, not pushed) | 6a38dd1
2026-11-14 01:52 | debian | ~/.claude/projects/-home-master/memory/ | memory note dotfiles-linux-portability.md + MEMORY.md index | n/a
2026-11-14 01:53 | debian | ~/NOTE-to-observer.md | final summary + proposed per-host essential lists | n/a
2026-11-14 01:56 | all | CHANGELOG-linux-portability.md (new) | this changelog, per observer request 02:00 | uncommitted
2026-11-14 01:56 | all | git | committed CHANGELOG-linux-portability.md (entries above marked uncommitted are in this commit) | fa7704b
2026-11-14 01:56 | debian | ~/NOTE-to-observer.md | posted STATUS: DONE (round 1) | fa7704b
