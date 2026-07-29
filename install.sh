#!/bin/bash
# Dotfiles entrypoint. Codespaces runs this automatically after cloning the
# dotfiles repo; it is also what .devcontainer/devcontainer.json calls.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "==> installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# ~/.local/bin is where the installer puts the `claude` binary
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || touch "$rc"
  grep -q 'HOME/.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  grep -q "alias cc=" "$rc" || echo "alias cc='claude'" >> "$rc"
done

echo "==> setting up zsh + powerlevel10k"
bash "$HERE/setup-zsh.sh"

echo "==> linking ~/.claude config"
bash "$HERE/setup-claude-config.sh"

if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
  echo "CLAUDE_CODE_OAUTH_TOKEN detected — no interactive login needed."
else
  echo "WARNING: CLAUDE_CODE_OAUTH_TOKEN is not set; you will be asked to log in."
fi
