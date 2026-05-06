#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[1;34m[info]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$1"; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || error "This bootstrap is macOS-only. See omerh/dotfiles for Linux."

# 1. Xcode Command Line Tools (git + compilers — required by Homebrew)
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools (a GUI dialog will appear; accept it)..."
  xcode-select --install || true
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  info "Command Line Tools installed"
else
  info "Xcode Command Line Tools already installed"
fi

# 2. Touch ID for sudo (one password prompt now, biometric for the rest of this script)
SUDO_LOCAL="/etc/pam.d/sudo_local"
if ! sudo grep -q '^auth.*pam_tid.so' "$SUDO_LOCAL" 2>/dev/null; then
  info "Enabling Touch ID for sudo..."
  echo 'auth       sufficient     pam_tid.so' | sudo tee "$SUDO_LOCAL" >/dev/null
  sudo chmod 644 "$SUDO_LOCAL"
else
  info "Touch ID for sudo already enabled"
fi

# 3. Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed"
fi

# 4. Everything from Brewfile (formulae, casks, taps, mas)
info "Installing packages from Brewfile..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# 5. Stow all packages
info "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow --target="$HOME" --restow zsh vim git ghostty gh ohmyposh zed

# 6. Default shell
ZSH_BIN="$(brew --prefix)/bin/zsh"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  info "Setting brew zsh as default shell..."
  grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_BIN"
  warn "Log out and back in for the shell change to take effect"
else
  info "zsh already the default shell"
fi

# 7. Lefthook hooks
info "Installing lefthook git hooks..."
lefthook install

info "Done. Open a new terminal — zinit will self-install on first shell."
info "Restore secrets with: tar -xzf <mac-sensitive-*.tar.gz> -C \$HOME"
