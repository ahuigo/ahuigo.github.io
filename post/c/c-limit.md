---
layout: page
title:	c limit
category: blog
description:
---
# c标准与限制
在unix advanced programming 中提到了c限制有两类：
1. 编译限制（头文件限制）：如（整型的长度）
2. 运行时限制：如文件名有多少个字符
    1. 与文件和目录无关的运行时限制 (sysconf函数)   e.g. `_SC_OPEN_MAX`
    1. 与文件和目录有关的运行时限制 (pathconf 和 fpathconf函数) e.g.`_PC_PATH_MAX`

标准与限制

    ## ISO C 限制
    其编译限制在 limits.h
    FOPEN_MAX 限制，同时打开的io流的最小个数。stdio.h 中定义的最小值是8.

    ## POSIX 
    包含了编译限制与运行限制 (sysconf函数, pathconf 和 fpathconf函数)

##  pathconf fpathconf

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
