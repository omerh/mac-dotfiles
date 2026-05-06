#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[1;34m[info]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$1"; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || error "This bootstrap is macOS-only. See omerh/dotfiles for Linux."

# 1. Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed"
fi

# 2. Everything from Brewfile (formulae, casks, taps, mas)
info "Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# 3. Stow all packages
info "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow --target="$HOME" --restow zsh vim git ghostty gh ohmyposh zed

# 4. Default shell
ZSH_BIN="$(brew --prefix)/bin/zsh"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  info "Setting brew zsh as default shell..."
  grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_BIN"
  warn "Log out and back in for the shell change to take effect"
else
  info "zsh already the default shell"
fi

# 5. Lefthook hooks
info "Installing lefthook git hooks..."
lefthook install

info "Done. Open a new terminal — zinit will self-install on first shell."
info "Restore secrets with: tar -xzf <mac-sensitive-*.tar.gz> -C \$HOME"
