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

# rules / skills をファイル単位のシンボリックリンクで展開（agents・hooks は除外）
stow --no-folding --ignore='agents' --ignore='hooks' -d "$DOTFILES_DIR" -t "$TARGET" ws-cursor

# agents / hooks はフォルダごとシンボリックリンクにする
# （Cursor はファイル単位のシンボリックリンクを Subagent として認識しないため）
symlink_dir() {
  local link="$1"
  local src="$2"
  local label="$3"

  if [ -L "$link" ]; then
    echo "$label symlink already exists, skipping."
  elif [ -d "$link" ]; then
    rm -rf "$link"
    ln -s "$src" "$link"
    echo "Replaced $label directory with folder symlink."
  else
    ln -s "$src" "$link"
    echo "Created $label folder symlink."
  fi
}

symlink_dir "$TARGET/.cursor/agents" "$DOTFILES_DIR/ws-cursor/.cursor/agents" "agents"
symlink_dir "$TARGET/.cursor/hooks"  "$DOTFILES_DIR/ws-cursor/.cursor/hooks"  "hooks"

echo "Done."
