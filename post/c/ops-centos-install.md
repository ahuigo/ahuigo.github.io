---
layout: page
title:	centos 安装记录
category: blog
description: 
---
# Preface
最近在公司安装centos6.5, 遇到了一些麻烦，在此记录一下。
>先下载了centos6.5.livecd.iso 然后dd到u盘。结果grub启动时，出现了efi错误，原来是启动后加载内核时因为root:LABEL=xxxx 中的LABEL(u盘标签)不对. 按e修改LABEL 为u盘的LABEL后启动liveCD成功。
> liveCD安装过程中，分区时被强制要求使用/boot/efi分区引导, 结果安装后才发现，bios不支持uefi 从efi分区引导。
> 没办法，又下载了centos6.5 minimal.iso 这下不用强制使用efi分区了。顺利安装成功。

	set -o errexit

# 网络配置

	# 默认配置是没有开启的
	sed -i 's/NETWORKING=no/NETWORKING=yes/' /etc/sysconfig/network
	service network start
	# ping weibo.cn -c 3

# yum 源配置

	# install wget
	yum install wget -y

	# 我直接使用网易163的源(快)。
	cd /etc/yum.repos.d/
	mv CentOS-Base.repo CentOS-Base.repo.bak
	wget http://mirrors.163.com/.help/CentOS6-Base-163.repo -O CentOS-Base.repo

	# refresh cache
	yum clean all
	yum makecache
	
	# check repo list
	yum repolist

# 工具

	# vim git zsh ..
	yum install vim-enhanced git zsh -y
	yum man man-pages -y

	# oh-my-shell
	cd ~
	wget --no-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | bash

	# autojump
	git clone git://github.com/joelthelion/autojump.git autojump
	cd autojump
	./install.py
	echo '[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh' >> ~/.zshrc
	echo 'autoload -U compinit && compinit -u' >> ~/.zshrc
	cd ~

# 服务配置
	# rsync (default port: 873)
	yum install rsync -y
	echo 'rsync --daemon --config=/etc/rsync.conf' >> /etc/rc.d/rc.local
	rsync --daemon --config=/etc/rsync.conf

	#ftp 
	yum install ftp vsftpd -y
	sed -i '/^#chroot_local_user/a chroot_local_user=YES' /etc/vsftpd/vsftpd.conf
	# 开机启动
	chkconfig --level 235 vsftpd on
	# 启动
	service vsftpd start
	
# php php-fpm php-mysql mysql nginx redis memcached

	#nginx 源
	cat > /etc/yum.repo.d/nginx.repo 
	[nginx] 
	name=nginx repo 
	baseurl=http://nginx.org/packages/centos/$releasever/$basearch/ 
	gpgcheck=0 
	enabled=1

	#centos 官方没有redis 源，可以使用fedora的源
	sudo rpm -Uvh  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	#https://webtatic.com/packages/php54/
	sudo rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm
	sudo yum install yum-plugin-replace -y


	#install php54 nginx mysql ...
	sudo yum install php54w php54w-devel nginx php54w-fpm mysql php54w-mysql php54w-gd php54w-mbstring php54w-mcrypt
	#sudo yum replace php-common --replace-with=php54w-common -y

	#install xdeubg
	# wget https://gist.githubusercontent.com/ahui132/0e808c805f496efa925e/raw/f48f610d0abbf67a976d517310b3d977a07d4fff/oh-my-xdebug -O - | sh
	cd ~
	set -o errexit
	git clone https://github.com/derickr/xdebug 
	cd xdebug
	phpize
	./configure --enable-xdeubg
	make
	sudo make install
	phpini=`php -i |grep -o -E 'Configuration File => [^[:space:]]+php\.ini' | awk '{print $4}'`
	[[ -z $phpini ]] && echo "Could not find php.ini!" && exit;
	extension_dir=`php -i | grep -o -E "extension_dir => [^[:space:]]+" | awk '{print $3}'`
	[[ -z $extension_dir ]] && echo "Could not find extension_dir!" && exit;
	sudo cat >> $phpini <<MM

	[xdebug]
	zend_extension=$extension_dir/xdebug.so
	;通过GET/POST/COOKIE:传XDEBUG_PROFILE触发
	xdebug.profiler_enable_trigger=1
	;通过GET/POST/COOKIE:传XDEBUG_TRACE触发
	xdebug.trace_enable_trigger=1
	MM
	cd ~
