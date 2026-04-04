#!/bin/bash
# Cursor プロジェクトに ws-cursor dotfiles をセットアップするスクリプト
#
# 使い方:
#   cd ${Workspace}
#   ~/dotfiles/scripts/setup-cursor-project.sh
#
# または対象ディレクトリを引数で指定:
#   ~/dotfiles/scripts/setup-cursor-project.sh /path/to/project

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-$(pwd)}"

echo "Setting up Cursor project dotfiles..."
echo "  dotfiles: $DOTFILES_DIR"
echo "  target:   $TARGET"

# rules / skills をファイル単位のシンボリックリンクで展開（agentsは除外）
stow --no-folding --ignore='agents' -d "$DOTFILES_DIR" -t "$TARGET" ws-cursor

# agents はフォルダごとシンボリックリンクにする
# （Cursor はファイル単位のシンボリックリンクを Subagent として認識しないため）
AGENTS_LINK="$TARGET/.cursor/agents"
AGENTS_SRC="$DOTFILES_DIR/ws-cursor/.cursor/agents"

if [ -L "$AGENTS_LINK" ]; then
  echo "agents symlink already exists, skipping."
elif [ -d "$AGENTS_LINK" ]; then
  rm -rf "$AGENTS_LINK"
  ln -s "$AGENTS_SRC" "$AGENTS_LINK"
  echo "Replaced agents directory with folder symlink."
else
  ln -s "$AGENTS_SRC" "$AGENTS_LINK"
  echo "Created agents folder symlink."
fi

echo "Done."
