---
title: c apue.sh
date: 2021-03-30
private: true
---
# 电子书pdf：
- git@gitee.com:ahuigo/ebook.git UNIX网络编程_卷1_目录版.pdf

# unpv1.3e 第一卷
Unix Network Programming(1) Verion 3: 有两处镜像可用
1. code1: https://github.com/unpbook/unpv13e
2. code2: https://github.com/ahuigo/unix-network-programming-v3 (debian 验证可用)
3. code3: https://github.com/ahuigo/unixCode  有点问题

# apue.3e: unix 环境 高级编程（第3卷）
https://unix.stackexchange.com/questions/105483/compiling-code-from-apue

source: https://github.com/ahuigo/c-lib/tree/apue/lib/apue.3e

## install command tool 'Command Line Tools' package

    open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg

## make apue
download http://www.apuebook.com/code3e.html

    $ export SCADDRESS=/Users/hilojack/www/apue.3e
    $ cd $SCADDRESS && make

## use apue
    gcc -o a.out read.c -I $SCADDRESS/include/ -L $SCADDRESS/lib/ -lapue
    gcc -o a.out read.c -I $SCADDRESS/include/

加入默认路径：

	ln -s ~/www/apue.3e/include/apue.h /usr/local/include/  
	ln -s ~/www/apue.3e/lib/libapue.a /usr/local/lib/
