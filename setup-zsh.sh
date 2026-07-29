#!/bin/bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# When run as dotfiles the container may have no zsh at all (devcontainer
# features only apply to the repo that owns the devcontainer).
if ! command -v zsh >/dev/null 2>&1; then
  echo "installing zsh + jq"
  sudo apt-get update -qq && sudo apt-get install -y -qq zsh jq
fi
command -v jq >/dev/null 2>&1 || sudo apt-get install -y -qq jq

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# point .zshrc at powerlevel10k instead of whatever theme is set
if grep -q '^ZSH_THEME=' "$HOME/.zshrc" 2>/dev/null; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
fi

# ship the pre-generated prompt config so the wizard never runs
cp "$HERE/p10k.zsh" "$HOME/.p10k.zsh"

if ! grep -q 'p10k.zsh' "$HOME/.zshrc" 2>/dev/null; then
  echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"
fi

# make zsh the login shell — devcontainer's configureZshAsDefaultShell is not
# available when we run as dotfiles, so do it by hand
ZSH_BIN="$(command -v zsh)"
if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  grep -qx "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  sudo chsh -s "$ZSH_BIN" "$(whoami)" && echo "default shell -> $ZSH_BIN"
fi

echo "zsh + powerlevel10k ready."
