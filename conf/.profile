#####################debug
#set -x

############ iterm2 #######
# key bindings
#bindkey "\e[1~" beginning-of-line
#bindkey "\e[4~" end-of-line
# CTRL+q
stty start undef
stty stop undef
bindkey \^U backward-kill-line
alias md='mkdir'
setopt share_history
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

############### system
ulimit -n 1000
export ENV_MODE=dev
export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export CLICOLOR="xterm-color"
export PATH=$PATH:$HOME/www/a/bin:~/bin:/usr/local/sbin
#$(pyenv root)/shims:
export GNUTERM=qt
export PROMPT='${ret_status}%{$fg_bold[green]%}%p%{$fg[cyan]%}%C$ %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}%(?..[%?])'$'\n$ '
# for ssh-host-machine: export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'

################# NVM ##############
echo "nvm.sh"
export NVM_DIR="$HOME/.nvm"
#source $(brew --prefix nvm)/nvm.sh
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"


# nvim
export EDITOR="nvim"
alias vi='nvim'
alias vim='nvim'
alias gpass='openssl rand -base64 10'
alias cp='cp -i'
alias svnst='svn st'
alias l='ls -lah'
alias code1='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'

# python
alias py='ipython3'
alias p='python3'
alias p2='python2'
alias pi='pip3'
alias pip='pip3'
export PYTHONPATH=.

# docker
alias drmi='docker rmi $( docker images --filter "dangling=true" -q --no-trunc)'


# brew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

#git
#sh ~/.git.bash

# git complete
#tree /usr/local/etc/bash_completion.d
#adb-completion.bash git-completion.bash git-prompt.sh

# git command
alias gitup='git submodule init && git submodule update'
alias ga.='git add .'
function lllllllllzrmv(){
    mv $2 $1;
}

#alias ts='ts-node'
function ts () {
	cwd_dir=$(pwd)
    tsc $1 && node --inspect ${1/.ts/.js} $@
    cd $cwd_dir
}

function current_repo() {
    echo -n `git remote -v | gawk 'NR==1{n=split($2,arr,"/"); print arr[n]}'`
}
function devops() {
	cwd_dir=$(pwd)
    repo=`current_repo` 
    from=`current_branch` 
    cd /Users/ahui/www/auto-devops/
    tsc devops.ts && node --inspect devops.js repo=$repo from=$from $@
    cd $cwd_dir
}
function goclean() {
    if [[ -z $1 ]]; then
        echo goclean  github.com/ahuigo/arun
        return
    fi
    echo "\$1=$1"
    echo 'sudo rm -rf ~/go/pkg/mod/'$1@\*
    sudo rm -rf ~/go/pkg/mod/$1@*
    echo 'rm -rf ~/go/pkg/mod/cache/download/'$1
    rm -rf ~/go/pkg/mod/cache/download/"$1"
}
function devops2() {
	cwd_dir=$(pwd)
    repo=`current_repo` 
    from=`current_branch` 
    cd /Users/ahui/www/auto-devops/
    tsc devops2.ts && node --inspect devops2.js repo=$repo from=$from $@
    cd $cwd_dir
}


# git -C dir
function gcap(){
    ori_dir=$(pwd)
	git commit -am $1;
    if test $? != 0;then
        return
    fi

    if git remote | grep '\w';then
        if git remote| grep -vE '^gitee|local|up|other$' | xargs -L1 -J% git push --follow-tags % HEAD; then
            cd $(git rev-parse --show-toplevel)
            subdirs=(b )
            top_dir=$(pwd)
            echo "check top_dir $top_dir"
            for subdir in "${subdirs[@]}"; do
                echo "check subdir $subdir"
                test -d $subdir && ! test -f $subdir/nopush && cd $subdir;
                if test $? = 0;then
                    echo git push $subdir;
                    subFullPath="$top_dir/$subdir"
                    echo $subFullPath
                    if [[ ${subFullPath%a/b} != $subFullPath ]];then
                        echo git pull
                        git pull -Xtheirs
                    fi
                    git add .
                    git commit -am "msg:$1"
                    git remote | xargs -L1 git push
                    cd $top_dir
                fi
            done
        fi
    elif git svn info | grep '\w';then
        echo git svn dcommit;
        git svn rebase;
        git svn dcommit;
    fi
    cd $ori_dir
}

# grep
unset GREP_OPTIONS
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
mcd(){ mkdir -p $@; cd $1;}
alias grepr='grep -rn -F'
grepr.(){ grep -rn $@ .}

# gbk
function iconvgbk(){
	if test $# -gt 0; then
		test -f $1 && iconv -c -f gbk -t utf-8  $1 > ~/tmp.txt && mv ~/tmp.txt $1 && echo "Successfully convert $file!";
	fi
}
function uniqfile(){
	if test $# -gt 0; then
		echo "waiting";
		sort $1 | uniq > ~/tmp.txt && mv ~/tmp.txt $1 && echo 'succ'
	fi
}

# loop shell command
function loop(){
	while true;do
		#printf "\r%s" "`$*`";
		printf "\n%s" "`$@`";
		sleep 1;
	done
}

# mda
function mda (){
        mkdir -p $1
        sudo chmod a+rwx $1
}

#alias for cnpm
alias cnpm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.cnpmrc"

alias yarn=tyarn

# z.lua
#eval "$(lua ~/conf/z.lua --init zsh)"

# app
export APP_ENV=dev

# deno
export PATH=$PATH:~/.deno/bin

# golang
export GODEV=local
export GO111MODULE=on 
export GOPATH=~/go
# 配置 GOPROXY 环境变量
export GOPRIVATE='*.internal.mycompany.com,github.com/ahuigo1,github.com/ahuigo2/requests'
export GOPROXY=https://goproxy.io,direct
#export GOSUMDB=gosum.io+ce6e7565+AY5qEHUk/qmHc5btzW45JVoENfazw8LielDsaI+lEbq6
export GONOSUMDB=*.corp.example.com,rsc.io/private
#export GOSUMDB=off

export PATH=$PATH:$GOPATH/bin:/opt/homebrew/opt/go@1.17/bin
#[[ -d $GOROOT ]] || export GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec
#[[ -d $GOROOT ]] || export GOROOT=/usr/local/Cellar/go/1.15.6/libexec
alias go14='export GOROOT=/usr/local/Cellar/go/1.14.3/libexec; ln -sf /usr/local/opt/go@1.14/bin/go /usr/local/bin/go'

# java
export JAVA_HOME="$(/usr/libexec/java_home)"
# /Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home
export JRE_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
#export CLASSPATH='.;./openjdk.jdk\lib\dt.jar'
export CLASSPATH=.:/usr/local/lib/jar:~/jar/json-simple-1.1.jar:/usr/local/lib/jar/java-json.jar
export CLASSPATH='.:/usr/local/lib/jar/*'
export CPPFLAGS="-I/usr/local/opt/openjdk/include"



[ -f ~/.private ] && source ~/.private
[ -f ~/.local.rc ] && source ~/.local.rc
