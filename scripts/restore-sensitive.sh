#!/usr/bin/env bash
# Restore a sensitive bundle produced by backup-sensitive.sh.
# Usage: restore-sensitive.sh [path/to/mac-sensitive-YYYYMMDD-HHMMSS.tar.gz]
# Defaults to the newest mac-sensitive-*.tar.gz on ~/Desktop.
set -euo pipefail

ARCHIVE="${1:-}"
if [[ -z "$ARCHIVE" ]]; then
  ARCHIVE="$(ls -t "$HOME/Desktop"/mac-sensitive-*.tar.gz 2>/dev/null | head -1 || true)"
fi

if [[ -z "$ARCHIVE" || ! -f "$ARCHIVE" ]]; then
  echo "Usage: $0 [path/to/mac-sensitive-YYYYMMDD-HHMMSS.tar.gz]" >&2
  echo "(no archive supplied and none found on ~/Desktop)" >&2
  exit 1
fi

echo "Archive: $ARCHIVE"
echo "Target:  $HOME"
echo
echo "First 15 entries:"
tar -tzf "$ARCHIVE" | head -15
echo "..."
total=$(tar -tzf "$ARCHIVE" | wc -l | tr -d ' ')
echo "(total $total entries)"
echo

read -r -p "Existing files at the same paths will be overwritten. Continue? [y/N] " ans
[[ "$ans" =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

# -p preserves the permissions tar captured at backup time
tar -xpzf "$ARCHIVE" -C "$HOME"

# Defensive permissions hardening for tools that refuse loose perms (ssh, gpg)
if [[ -d "$HOME/.ssh" ]]; then
  chmod 700 "$HOME/.ssh"
  find "$HOME/.ssh" -type f ! -name '*.pub' ! -name 'known_hosts*' -exec chmod 600 {} +
fi
if [[ -d "$HOME/.gnupg" ]]; then
  chmod 700 "$HOME/.gnupg"
  find "$HOME/.gnupg" -type f -exec chmod 600 {} +
fi
[[ -f "$HOME/.aws/credentials" ]] && chmod 600 "$HOME/.aws/credentials"
[[ -f "$HOME/.netrc" ]] && chmod 600 "$HOME/.netrc"

echo
echo "Restore complete. Quick smoke tests:"
echo "  ls -la ~/.ssh"
echo "  aws sts get-caller-identity 2>/dev/null || true"
echo "  kubectl config get-contexts 2>/dev/null || true"
echo "  gh auth status 2>/dev/null || true"
