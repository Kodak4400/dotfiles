DOTFILESDIR=$HOME/dotfiles
ZHOMEDIR=$DOTFILESDIR/.zsh

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

source $ZHOMEDIR/plugins.zsh
source $ZHOMEDIR/config.zsh
source $ZHOMEDIR/p10k.zsh

# Dockerの設定
export DOCKER_HOST=tcp://docker.local:2375

# PHPの設定
# PHPbrew使用のため、8.1を入れている
export PATH=/usr/local/opt/php@8.1/bin:$PATH
export PATH=/usr/local/opt/php@8.1/sbin:$PATH

export LDFLAGS=-L/usr/local/opt/php@8.1/lib
export CPPFLAGS=-I/usr/local/opt/php@8.1/include

# PHPbrewの設定
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

# Node（Volta）の設定
export VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin:$PATH

# Goの設定
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
