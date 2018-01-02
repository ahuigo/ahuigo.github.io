---
layout: page
title:	
category: blog
description: 
---
# Preface


# todo
http://linux.vbird.org/linux_basic/0440processcontrol.php#selinux

# chattr

	chattr [+-=][ASacdistu] 檔案或目錄名稱
	選項與參數：
	+   ：增加某一個特殊參數，其他原本存在參數則不動。
	-   ：移除某一個特殊參數，其他原本存在參數則不動。
	=   ：設定一定，且僅有後面接的參數
	a 只能增加
	i 不能增加,不能删除

lsattr 
	
	lsattr [-adR] 檔案或目錄
	選項與參數：
	-a ：將隱藏檔的屬性也秀出來；
	-d ：如果接的是目錄，僅列出目錄本身的屬性而非目錄內的檔名；
	-R ：連同子目錄的資料也一併列出來！ 

# selinux
Refer to [linux-selinux](/p/linux-selinux)

SELinux / AppArmor is preventing apache httpd from binding to a specific IP/PORT

	#check port
	semanage port -l|grep http

	# And add your favourite port to the existing policy:
	semanage port -a -t http_port_t -p tcp <PORT>

1.   查看SELinux设置

	# getsebool -a | grep ftp
	ftp_home_dir–>off
	allow_ftpd_full_access=>off

2.   使用setsebool命令开启

	setsebool -P ftp_home_dir 1 #-P 表示保存，否则它是临时生效
	sudo setsebool -P allow_ftpd_full_access 1

In `rw-rw-rw-+.`:

	. selinux ACL
	+ general ACL

Typing `getfacl .` in the current directory to see what access controls those files might have.

## 查询策略

	getsebool -a 

## 关闭selinux

	# 临时
	sudo setenforce 0
	# 永久关闭
	sudo sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config

