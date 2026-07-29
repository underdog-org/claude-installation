#!/bin/bash
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

# oh-my-zsh is installed by the devcontainer common-utils feature; guard anyway
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
cp "$(dirname "$0")/p10k.zsh" "$HOME/.p10k.zsh"

if ! grep -q 'p10k.zsh' "$HOME/.zshrc" 2>/dev/null; then
  echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> "$HOME/.zshrc"
fi

echo "zsh + powerlevel10k ready."
