---
title: ssh login
date: 2021-04-16
private: true
---
# ssh login
## ssh/scp　参数

    -p 22
    -C 启用压缩功能。经常用于scp
## 利用公私钥作验证(e.g.:RSA)
原理： 当ssh登录时,ssh程序会发送私钥去和服务器上的公钥做匹配.如果匹配成功就可以登录了

1. 本地只需要: .ssh/id_rsa

过程：
1.生成自己的公钥与私钥

	$ ssh-keygen -t rsa
	//or
	$ ssh-keygen -t rsa -P "passwd" -f ~/.ssh/id_rsa -C 'x@qq.com'

2.通过scp 或者ssh-copy-id 把公钥pub 传到远程

	#将pub 导入remote ssh server
    ssh-copy-id -p port -i ~/.ssh/id_rsa.pub root@192.168.12.10

    # 或直接覆盖(warning)
	scp ~/.ssh/id_rsa.pub user@host:/home/user/.ssh/authorized_keys

	#或者手动copy：
	cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"

	# 改变remote 权限，必须
	chmod 700 ~/.ssh
	chmod 600 ~/.ssh/authorized_keys
	chmod 600 -R ~/.ssh/* # 非必须

小结: 其实你可以一步到位：

	ssh-keygen -t rsa; ssh-copy-id user@host;
		-f ~/.ssh/id_rsa
		-t rsa/dsa
        -p change password

### 检验

	$ ssh -vT git@github.com-hilolt
	OpenSSH_6.2p2, OSSLShim 0.9.8r 8 Dec 2011
	debug1: Reading configuration data /Users/hilojack/.ssh/config
	debug1: /Users/hilojack/.ssh/config line 12: Applying options for github.com-hilolt
	debug1: Reading configuration data /etc/ssh_config
	debug1: identity file /Users/hilojack/.ssh/id_rsa_hilolt type 1

可参考：
http://www.cnblogs.com/weafer/archive/2011/06/10/2077852.html
http://www.chinaunix.net/old_jh/4/343905.html

## add password to private key
> https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
Adding or changing a passphrase

    ssh-keygen -p -f ~/.ssh/id_rsa

The first time you use your key, you will be prompted to enter your passphrase. 

If you choose to save the passphrase with your keychain(when add your key to the ssh-agent), you won't have to enter it again.

## sshagent
> https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent

1. If you choose to save the passphrase with your keychain(when add your key to the ssh-agent), you won't have to enter it again.
2. 如果有多个密钥，比如github, 就需要将密钥加入到ssh agent 客户端缓存代理

这个缓存代理, 将偿试不同的密钥

    # 启动agent
	eval "$(ssh-agent -s)"

    # 关闭
    ssh-agent -k

    # 加入密钥
    ssh-add -K ~/.ssh/other_id_rsa
        The -K option is Apple's standard version of ssh-add, which stores the passphrase in your keychain for you when you add an SSH key to the ssh-agent
        In MacOS Monterey (12.0), the -K and -A flags are deprecated and have been replaced by the --apple-use-keychain and --apple-load-keychain flags, respectively.

    # list
    ssh-add -l
    # you can delete all cached keys before
	ssh-add -D

如果想每个host 指定使用哪个密钥
参阅：[Multiple SSH Keys](https://gist.github.com/jexchan/2351996)
1. https://developer.github.com/guides/using-ssh-agent-forwarding/#your-key-must-be-available-to-ssh-agent

    #jexchan account
    Host github.com-ahuigo
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_rsa_ahuigo
    Host *
        UseKeychain yes

Config the fake `host` to be replaced , `name`, `email` in `.git/config`

    [remote "origin"]
        url = git@github.com-ahuigo:ahuigo/a.git

## rsync
rsync 是一个同步命令，它是通过ssh 来下的，如果同步时不想输入密码:

	rsync --rsh='sshpass -p password ssh -l username' host.example.com:path

## sshpass
如果想scp 不输入密码, 可以借助sshpass:

cat ssh_login.sh:

	#!/usr/bin/env bash
	sshpass -p password ssh "$@"
	sshpass -p "passwd" ssh yourUserName@host
	sshpass -p "passwd" ssh -l yourUserName host


Then:

	scp -S ssh_login.sh file user@host:path

## expect

	#!/usr/bin/expect
	spawn ssh -o StrictHostKeyChecking=no -l username hostname
	expect "password:"
	send "password\r"
	interact

## 堡垒机
穿过堡垒机传文件 有几个方法
1. scp 先传到堡垒机
2. ssh -N -f -L 2120:目标机IP:22 root@跳板机IP -p 跳板机端口
3. lrzsz: https://github.com/mmastrac/iterm2-zmodem
    1. 然后找到iTerm2的配置项：iTerm2的Preferences-> Profiles -> Default -> Advanced -> Triggers 添加triggers。
    2. 参考: https://yanyinhong.github.io/2017/12/26/How-to-use-lrzsz/
