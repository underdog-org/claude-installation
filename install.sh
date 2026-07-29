#!/bin/bash
set -euo pipefail

curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin is where the installer puts the `claude` binary
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  grep -q 'HOME/.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  grep -q "alias cc=" "$rc" || echo "alias cc='claude'" >> "$rc"
done

if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
  echo "CLAUDE_CODE_OAUTH_TOKEN detected — no interactive login needed."
else
  echo "WARNING: CLAUDE_CODE_OAUTH_TOKEN is not set; you will be asked to log in."
fi
