#!/bin/bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")/dotclaude" && pwd)"
DEST="$HOME/.claude"

mkdir -p "$DEST"

# Symlink (not copy) so edits made inside the container show up as repo diffs
# and can be committed straight back.
link() {
  local from="$SRC/$1" to="$DEST/$1"
  [ -e "$from" ] || return 0
  # only clobber a real file if it isn't already our symlink
  if [ -L "$to" ] || [ ! -e "$to" ]; then
    ln -sfn "$from" "$to"
  else
    mv "$to" "$to.bak"
    ln -sfn "$from" "$to"
    echo "  (existing $1 saved as $1.bak)"
  fi
  echo "  linked $1"
}

link settings.json
link statusline.sh
link hooks
link skills
link CLAUDE.md

chmod +x "$SRC/statusline.sh" "$SRC"/hooks/* 2>/dev/null || true

echo "~/.claude config linked from $SRC"
