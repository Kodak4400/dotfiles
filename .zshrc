# Shellの設定
PS1=$
alias ls='ls -G'
export LSCOLORS=gxfxcxdxbxegedabagacad

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
