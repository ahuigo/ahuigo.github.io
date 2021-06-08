---
layout: page
title:	c limit
category: blog
description:
---
# c标准与限制
在unix advanced programming 2.5.4/2.5.6 中提到了c限制有两类：
1. 编译限制（定义在unistd.h）：如（整型的长度）
2. 运行时限制：如文件名有多少个字符
    1. 与文件和目录无关的运行时限制 (sysconf函数判断)   e.g. `_SC_OPEN_MAX`
    1. 与文件和目录有关的运行时限制 (pathconf 和 fpathconf函数) e.g.`_PC_PATH_MAX`

获取值:

    long sysconf(int name);
    long pathconf(const char *pathname, int name);
    long fpathconf(int fd, int name);

打印值:

    long pr_sysconf(int name);
    long pr_pathconf(const char *pathname, int name);
    long pr_fpathconf(int fd, int name);

标准与限制

    ## ISO C 限制
    其编译限制在 limits.h
    FOPEN_MAX 限制，同时打开的io流的最小个数。stdio.h 中定义的最小值是8.

    ## POSIX 
    包含了编译限制与运行限制 (sysconf函数, pathconf 和 fpathconf函数)

## 最大可打开文件数
`_SC_OPEN_MAX`

    openmax = sysconf(_SC_OPEN_MAX) 

如果常量`_POSIX_RAW_THREADS`没有定义，则获取方法：

    openmax = sysconf(_SC_RAW_THREADS)

## 文件名有多少字符(pathconf fpathconf)
参考 unix编程书 2.5.4

    #ifdef _PC_PATH_MAX
        pr_pathconf("PATH_MAX is:", argv[1], _PC_PATH_MAX)
        errno = 0;
        if((val=pathconf(path,name))<0){
            printf(" %ld\n",val)
        }else{
            if(errno!=0){
                err_sys("pathconf error, path:%s", path )
            }else{
                fputs("no limit\n", stdout)
            }
        }
    #endif
