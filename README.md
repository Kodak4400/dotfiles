# dotfiles

## 使い方

```bash
# 1. Install stow https://www.gnu.org/software/stow/
brew install stow

# 2. Install eza https://github.com/eza-community/eza
brew install eza

# 3. Install bat https://github.com/sharkdp/bat
brew install bat

# 4. Install ripgrep https://github.com/BurntSushi/ripgrep
brew install ripgrep

# 5. Setup dotfiles (zsh & wezterm)
cd $HOME
stow -d ~/dotfiles -t . zsh
stow -d ~/dotfiles -t . wezterm

# 6. IDE
## Visual Studio Code
cd ${Workspace}
stow --no-folding -d ~/dotfiles -t . ws-code
## Cursor
cd ${Workspace}
~/dotfiles/scripts/setup-cursor-project.sh
# ※ Cursor は Subagents をファイル単位のシンボリックリンクで認識しないため、
#    agents ディレクトリのみフォルダごとシンボリックリンクにする必要がある。
#    このスクリプトがその差異を吸収する。
```

