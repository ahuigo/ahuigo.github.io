---
layout: page
title:
category: blog
description:
---

# tool
last #显示最后登录者
who #显示当前登录者
w：谁登录进来了
id：用户/组身份信息

# useradd

	useradd username -d /home/path
	echo '123456' | passwd username --stdin
	-s /sbin/nologin
	-M no Home Directory


# usermod
User Modifier

	usermod -l new-name old-name
	usermod -u new-uid loginname
	usermod -d /home/new-home name
    usermod -G staff,staff2 name # add group
    usermod -l newuser1 user #rename
    usermod -s /bin/zsh user

lock the account to prevent logging in:
Lock a user's password. This puts a '!' in front of the encrypted password

	usermod -L username 

# umask
设定新建文件的默认权限:
	for file: 666 - umask
	for dir: 777 - umask

	umask #显示
	umask -S #显示
	umask 022 # group -w-x other -w-x

# permission

	r (read contents in directory)： ls
	w (modify contents of directory)：touch rm mkdir mv (这些命令都需要x 权限做access)
	x (access directory)：cd ; ls -l ; ls --color=auto;
	rwx------. # `.`means an SELinux ACL (+ means a general ACL.)

注意:
	rwxr--r-- root users dir
	rwxrwxrwx root users dir/a

如果用id:id=501(hilojack) gid=20(users) 去访问dir:

	$ ls dir
	a
	$ ls --color=auto dir
	ls: cannot access dir/a: Permission denied

# chattr
Refer to [selinux](/p/linux-selinux)

	chattr [+-=][ASacdistu] 檔案或目錄名稱
	選項與參數：
	+   ：增加某一個特殊參數，其他原本存在參數則不動。
	-   ：移除某一個特殊參數，其他原本存在參數則不動。
	=   ：設定一定，且僅有後面接的參數

说明：

	a 只能增加
	i 不能增加,不能删除

lsattr

	lsattr [-adR] 檔案或目錄
	選項與參數：
	-a ：將隱藏檔的屬性也秀出來；
	-d ：如果接的是目錄，僅列出目錄本身的屬性而非目錄內的檔名；
	-R ：連同子目錄的資料也一併列出來！

# suid,sgid,sbit
suid/sgid 用于执行命令时转换用户/组身份. 但是用户原来的rwx权限不会改变. 以前不能r(read) 照样不能read
适用: suid只适用binary file(只适合binary file)
作用: 用户具备并且创建/改写/执行文件时，*uid身份*被替换成了*file 所属的用户*(创建文件的euid, 也会改变)

	hilo > test l a.out b.txt
	-rwxr-xr-x  1 hilojack  staff   137B Apr  3 14:54 a.out
	-rw-r-----  1 hilojack  staff     4B Apr  3 14:54 b.txt

	hilo > test ./a.out
	abc

	hilo > test sudo -u daemon ./a.out
		failed to open stream: Permission denied in a.out

必须设定suid:

	hilo > chmod u+s ./a.out

a.c:

	#include <string.h>
	#include <stdio.h>
	FILE *fp;
	char str[100];
	size_t n=100,ni=50;
	int main(void) {
		fp = fopen("b.txt", "r");
		fread(str, n,ni,fp);
		printf("%s", str);

		fp = fopen("/tmp/c.txt", "w");
		fwrite(str, n,3,fp);
		return 0;
	}

事实上，unix程序有两个身份:uid、euid, `chmod u+s` 改变的是euid, uid是执行时真正uid


	#include <stdio.h>
	#include <unistd.h>
	int main(void) {
		printf("Efective uid(euid):%d\n", geteuid());
		printf("Real uid(uid):%d\n", getuid());
		return 0;
	}

	$ gcc a.c; chmod u+s a.out; sudo -u daemon ./a.out
	Efective uid(euid):501
	Real uid(uid):1

适用: sgid 适用binanry file + directory
作用: 当用户对文件有写权限时，用户的*组身份*被替换为directory 或者 file 本身*所属的组*


sbit: sticky bit
适用: directory
作用: directory 下的文件, 自己和root 外的其它用户不能删除其中的文件. 默认的，如果用户对directory 有写权限就可以删除。sticky key 使得删除时还具备*自己的身份*。

用法:
	sudo chmod 3755 dir;
	sudo chmod g+s,o+t dir
	其中 SUID 為 u+s ，而 SGID 為 g+s ，SBIT 則是 o+t 囉！

# chmod
Clone ownership and permissions from another file?

	chown --reference=otherfile thisfile
	chmod --reference=otherfile thisfile
