#!/usr/bin/env bash
# Snapshot sensitive paths into a single tar.gz on the Desktop.
# Plain (unencrypted) — store the result in 1Password / iCloud / external disk.
set -euo pipefail

OUT="$HOME/Desktop/mac-sensitive-$(date +%Y%m%d-%H%M%S).tar.gz"

PATHS=(
  # SSH / cloud / k8s / GPG
  .ssh
  .aws
  .kube
  .gnupg
  .secrets
  .netrc

  # Container registry creds + Docker auth
  .docker/config.json
  .config/containers/auth.json

  # IDE / agent dirs (config + tokens mixed)
  .claude
  .claude.json
  .claude.json.backup
  .cursor
  .vscode
  .codex

  # JetBrains IDEs (WebStorm, IntelliJ, etc.) — macOS stores config under ~/Library
  #  "Library/Application Support/JetBrains"
  #  "Library/Preferences/com.jetbrains.WebStorm.plist"

  # Cloud SDK / tool creds living under .config
  .config/gcloud
  .config/stripe
  .config/op
  .config/1Password
  .config/raycast
  .config/NuGet
  .config/gh/hosts.yml
)

EXISTING=()
for p in "${PATHS[@]}"; do
  [[ -e "$HOME/$p" ]] && EXISTING+=("$p")
done

if [[ ${#EXISTING[@]} -eq 0 ]]; then
  echo "Nothing to back up." >&2
  exit 1
fi

tar -czf "$OUT" -C "$HOME" "${EXISTING[@]}"

echo "Wrote $OUT ($(du -h "$OUT" | cut -f1))"
echo "Contents:"
tar -tzf "$OUT" | head -30
echo "..."
echo
echo "Move this file into 1Password / iCloud / external disk before wiping the Mac."
echo "Restore on the new Mac with:  tar -xzf $(basename "$OUT") -C \$HOME"
