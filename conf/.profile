#####################debug
#set -x
alias todo='nvim ~/wk/todo.md'

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
#$(pyenv root)/shims:
export GNUTERM=qt
set +x
export PS1="%m:%~%$ 🌈 🏂 🏡  🌤️  🔥📌👋❌✅" # host
#export PS1="$(hostname -I | cut -d' ' -f1):%~%$ " # ip
#export PS1="$(hostname -I | cut -d' ' -f1):%~%$ $(git_prompt_info) "$'\n> '
#export PS1="%{$fg_bold[green]%}$(hostname -I | cut -d' ' -f1):%~%$ $(git_prompt_info) %{$reset_color%}%(?..[%?])"$'\n> '
export PROMPT='${ret_status}%{$fg_bold[green]%}%p%{$fg[cyan]%}%C$ %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}%(?..[%?])🌈 🏂 🏡  🌤️  🔥  ✅'$'\n$ '
if [[ -z $INIT_PROFILE ]]; then
    export PATH=$PATH:$HOME/www/py-lib/bin:$HOME/www/a/bin:~/bin:/usr/local/sbin
    # for ssh-host-machine: export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'
fi


###################### nvim + vscode #####################
export EDITOR="nvim"
alias vi='nvim'
alias vim='nvim'
alias gpass='openssl rand -base64 10'
alias cp='cp -i'
alias svnst='svn st'
alias l='ls -lah'
#alias code1=~/'Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
alias code=/'Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
alias code1='/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code'
alias code2='/Applications/Cursor.app/Contents/Resources/app/bin/code'
alias trae='open -a Trae'
alias code.='code .'
jc () {
        j ${1} && code .
}
alias cj=jc

##################### python ##########################################
if [[ -z $INIT_PROFILE ]]; then
    export PATH=/opt/homebrew/opt/python@3.10/bin:$PATH
    export PATH="$HOME/.poetry/bin:$PATH"
fi
if [[ -z $LDFLAGS ]];then
    # For compilers to find python@3.10 you may need to set:
    #export LDFLAGS="-L/opt/homebrew/opt/python@3.10/lib"
    #For pkg-config to find python@3.10 you may need to set:
    export PKG_CONFIG_PATH="/opt/homebrew/opt/python@3.10/lib/pkgconfig"
fi
alias py='ipython3'
alias p='python3'
alias p2='python2'
alias pip='python3 -m pip'
#export PYTHONPATH=.

####################### docker ###################################################
export DOCKER_DEFAULT_PLATFORM=linux/amd64
alias drmi='docker rmi $( docker images --filter "dangling=true" -q --no-trunc)'


# brew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
export HOMEBREW_NO_AUTO_UPDATE=1
#export HOMEBREW_CASK_OPTS=/opt/homebrew-cask/Caskroom


######################################## git #############################################
#sh ~/.git.bash

# git complete
#tree /usr/local/etc/bash_completion.d
#adb-completion.bash git-completion.bash git-prompt.sh

# git command
alias gitup='git submodule init && git submodule update'
alias ga.='git add .'

###################cicd #####################
function devops() {
	#cwd_dir=$(pwd)
    repo=`current_repo` 
    from=`current_branch` 
    deno run -A ~/www/auto-devops/devops.ts repo=$repo from=$from $@
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


########################## jq jd #####################
# jd a.json b.json
function jd() {
    vimdiff <(jq -S . $1) <(jq -S . $2) 
}

########################## git #####################
function current_repo() {
    echo -n `git remote -v | gawk 'NR==1{n=split($2,arr,"/"); print arr[n]}'`
}
# git -C dir
alias gcm='git commit -m'
function gcap(){
    ori_dir=$(pwd)
    noverify=$2
    if [[ $noverify == "no" ]];  then
        git commit -am "msg:$1" --no-verify
    else
        git commit -am $1;
    fi
    if test $? != 0;then
        return
    fi
    top_dir=$(git rev-parse --show-toplevel)
    origin_url=$(git remote get-url origin)
    if [[ $origin_url == ssh://devops.* ]]; then
        pathname=$(basename $top_dir)
        echo $pathname $1 >> ~/todo.md
    fi

    if git remote | grep '\w';then
        if git remote| grep -E '^(origin)$' | xargs -L1 -I% git push --follow-tags % HEAD; then
            cd $top_dir
            subdirs=( )
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
        # git svn rebase; git svn info; git svn dcommit;
    fi
    cd $ori_dir
}
# git rebase fetch
#alias gpr='git pull --rebase'
#git fetch $1 $2 && git rebase $1/$2

################################node #################################
function mocha1(){
    file=$1
    npx tsc -p $file && npx mocha --require "@babel/register" $file
}
function mocha(){
    npx mocha --require "@babel/register" $1
}

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
################### dict ##############
alias t=t.py

################ shell cli###########################
# grep
unset GREP_OPTIONS
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
mcd(){ mkdir -p $@; cd $1;}
compdef -d mcd
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
################### mysql postgres ######################
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
################ node:cnpm/yarn/pnpm #################
# pnpm
export PNPM_HOME=~/Library/pnpm
if [[ -z $INIT_PROFILE ]]; then
    export PATH="$PNPM_HOME:$HOME/.yarn/bin:$PATH:"
    #export PATH="$PATH:$(yarn global bin)"
fi
alias pnpx='pnpm exec'


# ts
#alias ts='ts-node'
function ts () {
	cwd_dir=$(pwd)
    tsc $1 && node --inspect ${1/.ts/.js} $@
    cd $cwd_dir
}


# app
export APP_ENV=dev

##################### bun ###########################
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH=$PATH:$BUN_INSTALL/bin

###########################deno & fresh######################
export FRESH_WATCH=1
export PATH=$PATH:~/.deno/bin:~/www/js-lib/bin
alias dr='deno run'
alias dt='deno test'
export PUPPETEER_EXECUTABLE_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

################ rust ###############
alias cg=cargo

################ flutter dart###############
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PATH="$PATH:$HOME/flutter/bin"
## android sdk
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT; #已弃用
# https://developer.android.com/tools
#export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:

################## java ########################
# export JAVA_HOME="$(/usr/libexec/java_home)"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home
export JRE_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
#export CLASSPATH=.:/usr/local/lib/jar:~/jar/json-simple-1.1.jar:/usr/local/lib/jar/java-json.jar
export CLASSPATH='.:/usr/local/lib/jar/*'
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

#################### golang ###############################
export GODEV=local
export GO111MODULE=on 
export GOPATH=~/go
# 配置 GOPROXY 环境变量
export GOPRIVATE='*.test.com,github.com/ahuigo1,github.com/ahuigo2/requests'
#export GOPROXY=https://goproxy.io,direct
#export GOSUMDB=gosum.io+ce6e7565+AY5qEHUk/qmHc5btzW45JVoENfazw8LielDsaI+lEbq6
export GONOSUMDB=*.corp.example.com,rsc.io/private
#export GOSUMDB=off
export PATH=/opt/homebrew/opt/go/bin:$PATH:$GOPATH/bin
alias go17='ln -sf /opt/homebrew/opt/go@1.17/bin /opt/homebrew/opt/go/bin'
#[[ -d $GOROOT ]] || export GOROOT=/usr/local/Cellar/go/1.15.6/libexec

######## other conf #############
[ -f ~/.private ] && source ~/.private
[ -f ~/.profile.local ] && source ~/.profile.local

export INIT_PROFILE=1
