# mac-dotfiles

My macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Mirrors the layout of my Linux [dotfiles](https://github.com/omerh/dotfiles), trimmed for macOS:
Homebrew (formulae + casks + taps) replaces apt + mise, no systemd auto-sync.

## Packages

| Package | What it manages |
|---------|-----------------|
| `zsh` | `.zshrc`, `.zshenv`, `.profile` (zinit auto-installs on first shell) |
| `vim` | `.vimrc` |
| `git` | `.gitconfig` and `.config/git/ignore` |
| `ghostty` | Ghostty terminal config (`~/.config/ghostty/config`) |
| `gh` | GitHub CLI `config.yml` (NOT `hosts.yml` — that has the auth token) |
| `ohmyposh` | Oh My Posh themes (`base.toml`, `zen.toml`) |
| `zed` | Zed editor `settings.json` |

Podman, gcloud, raycast, etc. aren't tracked — their state is Mac-specific and regenerated on first use of the tool.

## Quick start (new Mac)

```sh
git clone git@github.com:omerh/mac-dotfiles.git ~/personal/mac-dotfiles
cd ~/personal/mac-dotfiles
./install.sh
```

`install.sh` handles: Homebrew → `brew bundle install` from `Brewfile` (formulae, casks, taps, mas) → `stow` every package → set brew zsh as default shell → install lefthook git hooks. zinit self-installs from `.zshrc` on first shell open.

## Updating the Brewfile

```sh
brew bundle dump --file=Brewfile --describe --force
```

Run this any time you install/uninstall a brew package to keep the inventory current.

## Adding a new package

```sh
# Example: a new tool whose config lives at ~/.config/foo/config
mkdir -p ~/personal/mac-dotfiles/foo/.config/foo
mv ~/.config/foo/config ~/personal/mac-dotfiles/foo/.config/foo/
cd ~/personal/mac-dotfiles && stow foo
```

## Removing a package

```sh
cd ~/personal/mac-dotfiles && stow -D <package>
```

## Sensitive backup

Anything with credentials lives **outside git** in a one-shot tar.gz on the Desktop:

```sh
./scripts/backup-sensitive.sh
# → ~/Desktop/mac-sensitive-YYYYMMDD-HHMMSS.tar.gz
```

What's inside:

| Path | Why it's sensitive |
|------|--------------------|
| `.ssh/`, `.aws/`, `.kube/`, `.gnupg/`, `.netrc`, `.secrets` | Keys / credentials |
| `.docker/config.json`, `.config/containers/auth.json` | Registry auth |
| `.claude/`, `.claude.json*`, `.cursor/`, `.vscode/`, `.codex/` | API tokens + local state |
| `.config/gcloud/`, `.config/stripe/`, `.config/op/`, `.config/1Password/` | Cloud / vault sessions |
| `.config/raycast/`, `.config/NuGet/`, `.config/gh/hosts.yml` | App tokens |

The bundle is plain `tar.gz` — store it in 1Password / iCloud / an external disk before wiping the Mac.

Restore on the new machine:

```sh
tar -xzf mac-sensitive-*.tar.gz -C ~
```

## What's intentionally NOT tracked

Caches and regenerable state — `.cache/`, `.npm/`, `.zcompcache/`, `.zcompdump*`, `*_history`, `.cargo/`, `.rustup/`, `.aws-sam/`, `.terraform.d/plugin-cache`, `.dbt/`, `.duckdb/`, `.snowflake/`, etc. Brewfile + `install.sh` will recreate these on the new machine.

## Pre-commit

`lefthook.yml` runs [gitleaks](https://github.com/gitleaks/gitleaks) on staged changes. If a secret slips through, the commit is blocked.
