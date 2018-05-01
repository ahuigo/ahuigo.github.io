# init
sudo yum update -y
sudo yum install yum-utils -y
sudo yum groupinstall development -y
sudo yum install wget curl git mariadb zsh -y

# python3
sudo yum install https://centos7.iuscommunity.org/ius-release.rpm -y
sudo yum install python36u python36u-pip python36u-devel -y

# wget https://bootstrap.pypa.io/get-pip.py -O pip.py | python3
alias pip3=pip3.6
echo 'alias pip3=pip3.6' >>~/.bashrc
pip3 install --upgrade pip
pip3 install gunicorn 
#gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D

# zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
sudo yum install autojump autojump-zsh -y
sed -i  's/^# export PATH=/export PATH=/' ~/.zshrc
cat <<'MM' >> ~/.zshrc
export PS1='%n@%m%{$fg[cyan]%} %c%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}>%{$reset_color%}'
alias p='python3.6'
alias pi='pip3'
[ -f ~/.profile ] && source ~/.profile
#[[ -s /etc/profile.d/autojump.sh ]] && . /etc/profile.d/autojump.sh

export PYTHONPATH=.
MM

# lnmp
## rsync
sudo yum install rsync nginx -y
cat <<'MM' > /etc/rsyncd.conf
uid = www
gid = www
use chroot = no
max connections = 4
pid file = /var/run/rsyncd.pid
exclude = lost+found/
transfer logging = yes
timeout = 900
ignore nonreadable = yes
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

auth users = www
secrets file = /etc/rsync.secrets
list   = true
read only = false
[www]
path = /home/www
comment = ftp export area : comment
MM
echo 'www:123456' > /etc/rsync.secrets
chmod 600 /etc/rsync.secrets

## lnmp.sh
md ~/bin
cat <<'MM' > ~/bin/lnmp.sh
sudo pkill '[r]sync'
sudo rsync --daemon --config=/etc/rsyncd.conf --port=873
MM
useradd www -s /sbin/nologin -d /home/www
sudo chmod u+x ~/bin/lnmp.sh
