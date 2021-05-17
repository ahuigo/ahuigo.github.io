---
layout: page
title:	linux 之进程 error
category: blog
description:
---
# error
函数出错时会，一般返回负值errno. `man 2 intro` `man errno.h` 列出了常用的error 常量(errno.h)

     0 Error 0.  Not used.
     1 EPERM Operation not permitted. 
     2 ENOENT No such file or directory.
     3 ESRCH No such process.  
     13 EACCES Permission denied.

c 提供两函数用于打印出错信息: (c-lib/process/error.c)

    #include "apue.h"
    #include "errno.h"

    int main(int argc, char *argv[]){
        fprintf(stderr, "EACCES: %s\n", strerror(EACCES));
        errno = ENOENT;
        perror("ENOENT:");
        exit(0);
    }


## errno 的定义：
可以是整数 

    extern int errno

在线程中，所以每个线程有属于它局部的errno. 被定义：

    extern int *__errno_location(void)
    #define errno (*__errno_location(void))
