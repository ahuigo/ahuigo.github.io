---
title: 搭建 git server
date: 2018-09-27
---
# 搭建 git server
方案参考:
0. git-scm 教程
1. 廖老师的文章在本地建一个git server http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/00137583770360579bc4b458f044ce7afed3df579123eca000
2. mac参考：https://www.tomdalling.com/blog/software-processes/how-to-set-up-a-secure-git-server-at-home-osx/

## 1.create git user

    sudo adduser git

mac 可在UI中添加

## 2. sshd
1. linux: `systemctl start sshd`
2. macosx: 打开remote login, 并且Access allow for 设置成only these users: `git` (安全考虑)

测试

    ssh git@127.0.0.1

### 配置sshd
为了安全，我们应该禁用ssh 登录。
`sudo vim /etc/sshd_config`, mac下是`/etc/ssh/sshd_config`, change the following lines as indicated below.

    Find this line	                        Change it to this
    #PermitRootLogin prohibit-password      PermitRootLogin no
    #PasswordAuthentication yes             PasswordAuthentication no
    #ChallengeResponseAuthentication yes	ChallengeResponseAuthentication no
    UsePAM yes	                            UsePAM no

我们用id_rsa.pub 登录, 比如

	cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir /Users/git/.ssh; cat >> /Users/git/.ssh/authorized_keys"

如果没有authorized_keys, 会出现`Permission denied (publickey).`

### 配置git server
如果git 没有PATH执行git 命令：

    ssh git@127.0.0.1
    echo 'export PATH="$PATH:/usr/local/git/bin/"' >> /Users/git/.bashrc

## create bare git
git server 端的repo 应该是bare的（整个目录就是.git, 没有任何其它东西）

    git init --bare my_bare_repo.git
    git clone --bare /wherever/the/existing/repo/is.git

client 端使用：

    git clone ssh://git@mygit.dyndns.org:12345/Users/git/my_repo.git
    git clone ssh://git@127.0.0.1/Users/git/my_repo.git

faq: 
1. `git init --bare repo`如果不设置 GIT_DIR， 工作目录默认是当前目录
2. `ln -s ~/www/c-lib/.git  /Users/git/c-lib` 可行吗

## 管理公钥
如果团队很小，把每个人的公钥(*.pub)收集起来放到服务器的`/home/git/.ssh/authorized_keys` 文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。

## 管理权限 gitolite
Git也继承了开源社区的精神，自身不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。