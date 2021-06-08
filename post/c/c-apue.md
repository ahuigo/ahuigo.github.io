---
title: c apue.sh
date: 2021-03-30
private: true
---
# c apue.sh
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
