# init
sudo yum update
sudo yum install yum-utils -y
sudo yum groupinstall development
sudo yum install wget curl git mariadb zsh -y

# python3
sudo yum install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum install python36u python36u-pip python36u-devel -y

# wget https://bootstrap.pypa.io/get-pip.py -O pip.py | python3
pip3 install gunicorn 
gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D

# zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
sudo yum install autojump autojump-zsh
sed -i  's/^# export PATH=/export PATH=/' ~/.zshrc
cat <<'MM' >> ~/.zshrc
export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'
alias p='python3'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile
#[[ -s /etc/profile.d/autojump.sh ]] && . /etc/profile.d/autojump.sh
MM

# lnmp
md ~/bin
cat <<'MM' > ~/bin/lnmp.sh
sudo pkill '[r]sync'
sudo rsync --daemon --config=/etc/rsyncd.conf --port=873
MM
sudo chmod u+x ~/bin/lnmp.sh


# rsync
sudo yum install rsync

# web
sudo yum install nginx