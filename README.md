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

## Quick start (new Mac, cold start)

Order matters — the SSH key needed to clone this repo lives in the sensitive bundle, so restore that **first**.

```sh
# 1. Get mac-sensitive-*.tar.gz onto the Mac (iCloud / external drive / 1Password).
#    Then restore SSH keys, .gitconfig, AWS, kube, etc.:
tar -xpzf ~/Desktop/mac-sensitive-*.tar.gz -C ~

# 2. Clone (macOS pops the Command Line Tools dialog the first time `git` runs;
#    accept it and re-run the clone):
git clone git@github.com:omerh/mac-dotfiles.git ~/personal/mac-dotfiles

# 3. Bootstrap:
cd ~/personal/mac-dotfiles
./install.sh
```

`install.sh` handles: Xcode CLT (idempotent — usually already installed by step 2) → Homebrew → `brew bundle install` from `Brewfile` (formulae, casks, taps) → `stow` every package → set brew zsh as default shell → install lefthook git hooks. zinit self-installs from `.zshrc` on first shell open.

Expect to be present at the keyboard during the run: `sudo` password (for `/etc/shells` + some casks), and a few cask-specific GUI installers (1Password, Tailscale, etc.). If a couple of `vscode --install-extension` lines fail on the first pass, re-run `brew bundle install --file=Brewfile` to catch them.

After the dotfiles install, see [Manual installation](#manual-installation-not-in-brewfile) for Mac App Store apps and vendor-only downloads.

Restore the rest of the bundle later with:

```sh
./scripts/restore-sensitive.sh   # idempotent — runs on already-restored bundle too
```

(You can also skip step 1 above and run `restore-sensitive.sh` after install if you'd rather; you'll just need to clone via HTTPS + paste a GitHub token.)

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
./scripts/restore-sensitive.sh                              # newest tar.gz on ~/Desktop
./scripts/restore-sensitive.sh /path/to/mac-sensitive-*.tar.gz   # explicit path
```

The script previews the archive, prompts before extracting, runs `tar -xpzf` to preserve permissions, then re-tightens `.ssh`, `.gnupg`, `.aws/credentials`, and `.netrc` defensively (700 / 600) in case the source perms drifted.

## Manual installation (not in Brewfile)

Some apps can't be reinstalled by `./install.sh` and need a manual step on the new Mac.

### Mac App Store

These were installed via the Mac App Store. To track them in the Brewfile, install [`mas`](https://github.com/mas-cli/mas) and re-run `brew bundle dump`:

```sh
brew install mas
mas list                                          # see what's signed in
brew bundle dump --file=Brewfile --describe --force
```

| App | Notes |
|-----|-------|
| TickTick | |
| 1Password for Safari | Safari extension |
| Microsoft Word / Excel / PowerPoint / Outlook / Teams | Office 365 — login required after install |
| Ghostery Privacy Ad Blocker | |
| WorkSpaces | AWS WorkSpaces client |
| Gemini | Verify whether this is the MAS or direct version |

### Vendor-only downloads (no cask available)

| App | Source |
|-----|--------|
| DisplayLink Manager | [displaylink.com](https://www.displaylink.com/downloads/macos) — required if using a DisplayLink dock |
| Logitech Options+ | [logitech.com](https://www.logitech.com/software/logi-options-plus.html) — for MX/Logitech peripherals |

### Comes with macOS / auto-installed

- Safari (system app)
- Claude Code URL Handler.app — installed automatically by Claude Code on first run

## What's intentionally NOT tracked

Caches and regenerable state — `.cache/`, `.npm/`, `.zcompcache/`, `.zcompdump*`, `*_history`, `.cargo/`, `.rustup/`, `.aws-sam/`, `.terraform.d/plugin-cache`, `.dbt/`, `.duckdb/`, `.snowflake/`, etc. Brewfile + `install.sh` will recreate these on the new machine.

## Pre-commit

`lefthook.yml` runs [gitleaks](https://github.com/gitleaks/gitleaks) on staged changes. If a secret slips through, the commit is blocked.
