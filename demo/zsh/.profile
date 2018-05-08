#export
export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export EDITOR="vim"
export CLICOLOR="xterm-color"
export PATH=$PATH:$HOME/www/a/bin:$HOME/bin
export GNUTERM=qt
export PROMPT='${ret_status}>%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}%{$reset_color%}'
export JAVA_HOME="$(/usr/libexec/java_home -v 1.7)"
export PIP_FORMAT=columns

ulimit -n 1000

# alias
alias vi='mvim'
alias cp='cp -i'
alias svnst='svn st'
alias l='ls -lah'

# python
alias py='ipython3'
alias p='python'
export PYTHONPATH=.


#android sdk
export PATH=$PATH:~/.composer/vendor/bin:/Users/hilojack/Downloads/n5/platform-tools

# go
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

# brew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles


#git
#sh ~/.git.bash

# git complete
#tree /usr/local/etc/bash_completion.d
#adb-completion.bash git-completion.bash git-prompt.sh

# git command
alias gitup='git submodule init && git submodule update'
alias ga.='git add .'
function gcap(){
	git commit -am $1;
    if git remote | grep '\w';then
        echo git push;
        git push;
    else
        echo git svn dcommit;
        git svn rebase;
        git svn dcommit;
    fi
}

# grep
unset GREP_OPTIONS
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn'
mcd(){ mkdir -p $@; cd $1}
alias rgrep='grep -rn -F'
rgrep.(){ grep -rn $@ .}

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

[ -f ~/.private ] && source ~/.private
