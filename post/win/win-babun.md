babun: 封装了cygwin, 开箱即用。
1. 提供git
2. oh-my-zsh
3. pact install python3

## install 


## pact 镜像
默认国外的mirrors太慢了，修改~/.pact/pact.repo
ftp://ftp.iij.ad.jp/pub/cygwin/

    PACT_REPO=http://mirror.pkill.info/cygwin/
    #PACT_REPO=http://mirrors.kernel.com/sourceware/cygwin/
    # full list
    ## http://cygwin.com/mirrors.html

## cmd
netstat -nat |findstr 1111 ;# 查看tcp 端口
where python; # like which in linux