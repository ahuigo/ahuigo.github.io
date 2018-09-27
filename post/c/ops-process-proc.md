---
title: /proc
date: 2018-09-27
---
# /proc

    # sudo fuser 9000/tcp
    9000/tcp:            16267


    # ls -l /proc/16267/
    exe -> /usr/bin/python3.6
    cwd -> /home/test

## 加载的动态库

    $ cat /proc/16267/maps 
    00400000-00401000 r-xp 00000000 ca:01 2249510                            /usr/bin/python3.6
    ....
    7fa99842a000-7fa99842e000 r-xp 00000000 ca:01 529337                     /usr/lib64/python3.6/lib-dynload/termios.cpython-36m-x86_64-linux-gnu.so

## cmdline

    $ cat /proc/16267/cmdline
    python3/srv/awesome/www/app.py

## process info
uid/gid/name/rss(实际内存)/vss(虚拟内存)

    $ cat /proc/16267/status
    Name:   python3
    State:  S (sleeping)
    Tgid:   16267
    Pid:    16267
    PPid:   16266
    TracerPid:      0
    Uid:    1002    1002    1002    1002
    Gid:    1002    1002    1002    1002
    FDSize: 64
    Groups: 1002
    VmPeak:   257884 kB
    VmSize:   252492 kB
    VmRSS:     26036 kB
    ....

## other
```
### statck 调用栈
$ cat /proc/16267/stack

# 不知道里面是什么数据
$ cat /proc/16267/stat
16267 (python3) S 16266 16266 16227 34818 .....
$ cat /proc/16267/statm
```