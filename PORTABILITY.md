# Portability notes: macOS ↔ Debian/Linux (headless)

Branch `linux-portability`. First target: Debian 13 (trixie), amd64, headless server
(no desktop environment), reached over SSH. Goal: one chezmoi source tree that sets up
both a MacBook and a Linux box. **Principle: guard, don't delete.** macOS behaviour
should be unchanged by everything below.

## Host types

Decided once in `chezmoi/.chezmoi.toml.tmpl`, read everywhere else as template data:

| `.chezmoi.os` | `.pkgmgr` | `.headless` | Host |
|---|---|---|---|
| darwin | `brew` | false | MacBook (GUI) |
| linux, Debian/Ubuntu family | `apt` | true unless `/usr/share/{xsessions,wayland-sessions}` exists | vault-host etc. |
| anything else | `""` | true | OS package step prints a message and is skipped; apply still succeeds |

After pulling this branch on an existing machine, run **`chezmoi init`** once to regenerate
`~/.config/chezmoi/chezmoi.toml` from the template (chezmoi warns until you do). On the Mac this
also carries over the iTerm2 `plutil` pre-add hook (previously the repo-root `chezmoi.toml`, which
chezmoi never read automatically. That file can be deleted once the Mac uses the template).

## Mac rollout

1. `cd ~/.local/share/chezmoi && git fetch && git switch linux-portability` (after pushing it from wherever it was committed)
2. `chezmoi init`: regenerates `~/.config/chezmoi/chezmoi.toml` from `.chezmoi.toml.tmpl` (`headless=false`,
   `pkgmgr="brew"`, umask, plutil pre-add hook). Scripts read the data with `get`, so an apply before this
   step doesn't fail: the OS package script just renders empty.
3. `chezmoi diff`: expect only intended changes (gitconfig template output, iTerm2 script guard, shell-file
   guards, mise config identical). The changed mise scripts will run once (`mise install`; the mise bootstrap skips because mise is present).
4. Review, then `chezmoi apply`.

## How the split works

| Mechanism | Where | Purpose |
|---|---|---|
| `.chezmoi.toml.tmpl` | config | `headless`, `pkgmgr` data; `umask = 0o022` so file modes don't depend on the caller's shell |
| `.chezmoiignore` (templated) | `chezmoi/.chezmoiignore` | Skip macOS-only targets on non-darwin |
| `{{ if eq .chezmoi.os "darwin" }}` | scripts, templates | Script renders empty → chezmoi skips it |
| `[[ "$OSTYPE" == darwin* ]]` | `.aliases`, `.zshrc`, `.zshenv` | Runtime guards; keeps files plain (no `.tmpl`) so `chezmoi add`/`re-add` keep working |
| `command -v X &&` | `.zshrc`, `.aliases`, `.kubectl-profile` | Tool may not be installed yet (or ever) on a host |
| `dot_config/mise/config.toml.tmpl` | mise | Shared tools at top; `{{ if eq .chezmoi.os "linux" }}` block for tools brew provides on macOS |
| `run_before_05_os-packages.sh.tmpl` | scripts | apt counterpart to `run_onchange_brew-packages.sh.tmpl` (keyed on `.pkgmgr`) |
| `{{ if lookPath "vim" }}` | Vundle script | renders empty until vim exists, so the run_once isn't spent before vim is installed |

Package source of truth: **macOS → `dot_Brewfile`; Linux → apt script + linux block of mise config.**
When adding a tool to the Brewfile, also add it to one of those two (or note why not, below).

## File-by-file changes

### New
- `chezmoi/.chezmoiignore`: on non-darwin ignores `.Brewfile`, `.macos`, `.config/iterm2`,
  `Library/` (VS Code macOS settings path), `macos-diff`, `macos-snapshot`,
  `update-claude-credentials` (edits `~/Library/Application Support/Code/...`).
- `chezmoi/.chezmoi.toml.tmpl`: host-type data (see above).
- `chezmoi/.chezmoiscripts/run_before_05_os-packages.sh.tmpl`: when `pkgmgr == "apt"`.
  A `run_` (every apply) script, not `run_onchange_`: it only does a cheap `dpkg-query` check, and
  a skipped install must be retried next time. **Never prompts**: uses sudo only if `sudo -n true`
  succeeds (or running as root); otherwise lists what it skipped and says to run
  `sudo -v && chezmoi apply`. Also symlinks `bat`→`batcat` and `fd`→`fdfind` into `~/.local/bin`
  and `chsh`es to zsh. Adds `git-gui` only when not headless. On unknown Linux distros it prints a
  "no OS package step" message instead.

### Changed (both OSes)
- `run_once_after_install-iterm2-settings.sh.tmpl`: **bug fix**: was not darwin-guarded
  (would run `defaults write` on Linux). Now wrapped in a darwin guard.
- `run_once_after_20_install_vundle.sh` → `.tmpl`, wrapped in `{{ if lookPath "vim" }}`.
  Rendered bytes on the Mac are identical, so it won't re-run there.
- `run_once_before_01_install_mise.sh`: skips the `curl | sh` if `~/.local/bin/mise` exists.
- `run_once_after_10_mise_install.sh` → `run_onchange_after_10_mise_install.sh.tmpl`:
  re-runs `mise install` whenever the mise config template changes (previously ran once ever,
  so tools added later never got installed by `chezmoi apply`).
- `dot_config/mise/config.toml` → `.tmpl` with a linux-only block (see table below).
  ⚠ Because it's a template, `mise use -g …` edits to `~/.config/mise/config.toml` get overwritten on
  the next apply. Use `chezmoi edit ~/.config/mise/config.toml` instead (README updated).
- `dot_gitconfig` → `dot_gitconfig.tmpl`:
  - `init.templatedir` was hardcoded `/Users/lhunt/...` → `{{ .chezmoi.homeDir }}`, and only
    emitted if `~/.git-templates` exists (otherwise git warns on every clone/init).
  - gh credential helper: macOS keeps absolute `/opt/homebrew/bin/gh` (GUI apps lack brew
    on PATH); Linux uses `~/.local/share/mise/shims/gh`.
  - ⚠ Since it's a template now, `chezmoi re-add` skips it. Use `chezmoi edit ~/.gitconfig`.
- `dot_zshrc`:
  - atuin, thefuck, mise activation, `go env GOPATH`, VS Code shell integration: guarded by `command -v`.
  - pyenv init: only if `pyenv` exists (was unconditional and called `pyenv init -` twice).
  - conda block: only if `~/miniconda3` exists.
  - Rancher Desktop PATH, `/opt/homebrew/opt/{libpq,make}` PATHs: darwin only.
  - `alias assume="source assume"` (was `/opt/homebrew/bin/assume`; zsh `source` searches PATH).
  - `stty stop undef` only when stdin is a TTY (avoids noise for `ssh host cmd`).
  - `ulimit -n 2048 2>/dev/null`.
- `dot_zprofile`: pyenv shim juggling only if `pyenv` exists.
- `dot_zshenv`: on Linux prepend `~/.local/bin` and mise shims to PATH. zsh never reads
  `~/.profile`, where Debian/cloud-init put those. *Candidate for macOS too.*
- `dot_aliases`:
  - Wrapped in darwin guards: `update`, `ip`/`localip`/`ips`, `flush`, `lscleanup`, `sniff`,
    `httpdump`, `emptytrash`, `show`/`hide`, `hidedesktop`/`showdesktop`, `spotoff`/`spoton`,
    `plistbuddy`, `stfu`, `pumpitup`, `chromekill`, `afk`, `minikube` (hyperkit).
  - Linux equivalents: `update` (apt + `mise upgrade` + `chezmoi update`), **`myip`** (not `ip`:
    aliasing `ip` would shadow iproute2's `ip` command), `localip` (`hostname -I`), `ips`
    (`ip -br addr`), `flush` (`resolvectl`), `httpdump` (`-i any`).
  - `pbcopy` on Linux = OSC 52 escape → copies to the clipboard of the *local* terminal over SSH.
    iTerm2 needs "Applications in terminal may access clipboard" enabled. So `c` works.
    There is no `pbpaste` equivalent (OSC 52 read is generally disabled), so `awspaste` is still mac-only in practice.
  - `secret-set/get/delete/export`: macOS keychain unchanged. Linux (no keychain/D-Bus on a
    headless box) uses age-encrypted files in `~/.local/share/secrets/`, identity
    `~/.config/age/secrets.key` (0600, auto-generated). This protects against accidental leaks
    (grep, backups, sync), not against someone with your account. Same CLI.
  - `cat=bat`, `less/more=moor` only if those commands exist (otherwise `less` broke).
  - `ctags` alias only if `brew` exists (was `$(brew --prefix)` → error on Linux).
  - `urlencode` was Python 2 (broken everywhere) → Python 3.
- `dot_kubectl-profile`: `kubectl completion` only if kubectl exists; `complete -F` lines only if
  `complete` is defined (needs `bashcompinit`; otherwise "command not found" in zsh).

### Unchanged but noteworthy
- `.vimrc` + Vundle script: portable. Needs `vim` (apt script installs it; Debian ships only vim-tiny/none).
- `xpand()` in `.aliases` uses `BASH_ALIASES`: bash-only, broken under zsh on both OSes.
- `core.excludesfile = ~/.global_gitignore` points at a file the repo doesn't track.
- `merge "json"` driver needs `git-json-merge` (npm), which isn't installed anywhere.
- `chezmoi.toml` (repo root) pre-add hook calls `plutil` but only for the iTerm2 plist, so it's harmless on Linux.
- `dot_zprofile` OrbStack line already fails silently.
- `.zshrc` `plugins=(git ruby zsh-aws-vault)` is an oh-my-zsh variable; with znap it does nothing.

## Brewfile → Linux mapping

### apt (Debian trixie main)
`adr-tools age gnupg gnutls-bin atuin awscli bat cmake cookiecutter cosign python3-cryptography
direnv python3-docutils libimage-exiftool-perl eza fd-find ffmpeg fswatch git git-crypt git-delta
git-filter-repo git-secrets glow htop hub jq just kubectl postgresql-client make miller pandoc
pipx pre-commit ripgrep shellcheck shfmt starship thefuck tree universal-ctags virtualenv wget
zoxide sshpass openvpn`, plus things macOS ships but Debian doesn't: `zsh vim fzf curl unzip
bind9-dnsutils libwww-perl build-essential pkg-config libssl-dev`. (`dnsutils` is only a virtual name in trixie, so a dpkg-query check never sees it as installed.)

Name differences: `gnutls`→`gnutls-bin`, `cryptography`→`python3-cryptography`,
`docutils`→`python3-docutils`, `exiftool`→`libimage-exiftool-perl`, `fd`→`fd-find` (binary `fdfind`),
`bat` (binary `batcat`), `kubernetes-cli`→`kubectl`, `libpq`→`postgresql-client`.

`fzf` isn't in the Brewfile, but `zsh-fzf-history-search` needs it. *Add `brew "fzf"` on macOS too.*

### mise (Linux block): missing or stale in apt
| Tool | Why mise |
|---|---|
| go, gh, gitleaks | apt versions stale (1.24 / 2.46 / 8.16) |
| rust (stable) | replaces brew `rust` + `rustup` |
| chezmoi | not in Debian |
| difftastic hadolint k9s sops stern tilt k6 pnpm golangci-lint cargo-binstall kubecolor granted pulumi bun snyk scorecard | not in Debian |
| aws-vault | registry points to the ByteNess fork (maintained successor of 99designs). On Linux set `AWS_VAULT_BACKEND=file` (or `pass`): no keychain |
| terraform | replaces brew `tenv`/`tfenv` |
| github:walles/moor, github:rtk-ai/rtk, github:charmbracelet/pop | not in registry/apt |
| github:tbillington/kondo (prebuilt), cargo:mergiraf, cargo:claudelytics | Brewfile `cargo` entries + kondo. cargo:mergiraf/claudelytics came down as binstall prebuilts; source builds need `build-essential` |
| pipx:llm, pipx:trafilatura, pipx:git-remote-codecommit, pipx:mitmproxy | Brewfile `uv` entry + python formulas/casks |
| npm:graphql-cli | |
| go:… (all Brewfile `go` entries) | Brewfile `go` entries |

*Idea:* the Brewfile's `go`/`cargo`/`uv` entries and many CLI formulas could move to the
**shared** part of the mise config, so they're defined once for both OSes.

### Deliberately not brought to the headless Linux box
| Brewfile entry | Reason |
|---|---|
| `duti`, `mas` + all `mas` apps (GarageBand, iMovie, Xcode, HP, Trello) | macOS-only |
| all casks | GUI apps, no desktop here. Exceptions handled elsewhere: claude-code (already installed via native installer), gcloud-cli (add Google's apt repo if needed), ngrok (apt repo if needed), copilot-cli (`npm i -g @github/copilot` if needed), font-hack-nerd-font (fonts live on the *client* terminal, not the server) |
| `git-gui`, `tcl-tk` | GUI |
| `docker` | docker-ce already installed from Docker's apt repo |
| `unbound` | It's a DNS resolver daemon: the apt package would start a service on :53. In brew it was only a dependency of gnutls |
| `icu4c@78`, `libxml2` | brew build deps only |
| `nvm`, `pyenv`, `pyenv-virtualenv` | superseded by mise (node 24 / python 3.13 already in mise config) |
| `ccat` | redundant with `bat` (`cat` is aliased to bat) |
| `snap`, `snapcraft` | brew `snap` is a `.snap` file tool; not useful on a headless dev box |
| `appium` | mobile UI testing; needs device/emulator tooling |
| `hub` | kept (apt), but deprecated upstream in favour of `gh` |
| `go "golang.org/x/tools/cmd/guru"`, `gorename` | guru removed from x/tools upstream (fails on macOS too); gorename resolves to a `0.1.0-deprecated` stub. Use `gopls` rename |
| `go "github.com/lancehunt/ideas/cmd/ideas"` | private repo; this host has no GitHub credentials (only vault deploy keys), so it fails `mise install` and with it `chezmoi apply`. Install manually where creds exist (`GOPRIVATE=github.com/lancehunt go install ...`) |
| VS Code extensions | install on the remote automatically via VS Code Remote-SSH |

## Host-specific things on this Debian box (not managed by chezmoi, leave alone)
`~/.local/bin/{vault-init,vault-sync,claude,mise}`, `~/.config/systemd/user/vault-git@*`,
`~/.ssh/config` + `vault_*` deploy keys, `~/vaults/`. chezmoi only adds files to `~/.local/bin`
and never deletes unmanaged files there.

## Verification done on vault-host (Debian 13, 2026-11-14)
- `chezmoi apply` **with scripts**, no TTY, no sudo: exit 0, no prompts. Second run: no file changes;
  `chezmoi status` only lists the always-run package check (by design).
- macOS renders simulated with `execute-template` (`.chezmoi.os` → darwin): mise config, iTerm2 script
  and Vundle script are byte-identical to `main`. gitconfig is identical except `templatedir`, which is
  only emitted when `~/.git-templates` exists (true on the Mac).
- zsh (tested from an extracted zsh .deb, since apt needs sudo): interactive login starts with no warnings;
  `env -i … zsh -c 'command -v claude mise node'` resolves via `~/.zshenv`, same as `~/.bashrc` line 1.
- Vault sync timers still green after apply; vault-sync's git calls aren't affected by the new ~/.gitconfig.
- `gitleaks dir .`: no leaks.

## Not verified / follow-ups
- Nothing ran on macOS. Lance to check: `chezmoi init && chezmoi diff` on the Mac should show only intended changes.
- apt step and `chsh` pending Lance's sudo: `sudo -v && chezmoi apply`.
- `pre-commit run --all-files` not run (pre-commit arrives with the apt step).
