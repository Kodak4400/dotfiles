# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

DOTFILESDIR=$HOME/dotfiles
P10KDIR=$DOTFILESDIR/p10k

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# AWS設定（CL）
# export AWS_PROFILE=cl-aws

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

source $P10KDIR/plugins.zsh
source $P10KDIR/config.zsh
source $P10KDIR/p10k.zsh

# Dockerの設定
#export DOCKER_HOST=tcp://docker.local:2375

# asdfの設定
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# PHPの設定
# PHPbrew使用のため、8.1を入れている
# export PATH=/usr/local/opt/php@8.1/bin:$PATH
# export PATH=/usr/local/opt/php@8.1/sbin:$PATH
# export LDFLAGS=-L/usr/local/opt/php@8.1/lib
# export CPPFLAGS=-I/usr/local/opt/php@8.1/include

# PHPbrewの設定
# [[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

# Node（Volta）の設定
export VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin:$PATH

# Goの設定
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/t-toda/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# bun completions
[ -s "/Users/t-toda/.bun/_bun" ] && source "/Users/t-toda/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# poetry(python)の設定
fpath+=~/.zfunc
# poetry completions zsh > ~/.zfunc/_poetry

# Alias
alias ls='eza'
alias ll='eza -l'
alias grep='rg'
alias cat='bat'




# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
