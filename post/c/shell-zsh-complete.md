---
title: zsh 命令补全原理
date: 2020-09-28
private: true
---
# zsh 命令补全原理
参考：

## 参数自动补全
补全命令

    #compdef cli-test.sh
    # filename: _cli-test.h

    _cli_test() {

        _arguments -C -s -S \
                '-h::' \
                '-u::' \
                '-d::' \
                '-p::'
    }

    _cli_test "$@"

zsh 中有个 fpath 的内置变量，将自动补全脚本放在 $fpath 中，或者在 $fpath 中创建指向自动补全的脚本的软连接都可以。 下面是我的环境中 fpath 的值

    $ echo $fpath
    /usr/local/share/zsh/site-functions /Users/ahui/.oh-my-zsh/plugins/autojump /Users/ahui/.oh-my-zsh/plugins/git /Users/ahui/.oh-my-zsh/functions 

为了测试 zsh 下自动补全是否有效，我在 fpath 下给自己的自动补全脚本创建了软连接

    $ ln -s ~/projects/bash/autocomp/_cli-test.sh /usr/local/share/zsh/site-functions/_cli-test.sh

测试结果

$ ./cli-test.sh -<TAB><TAB>
-d  -h  -p  -u
可以看出，zsh 的补全方法非常简单直观。稍微解释下上面的代码

## _arguments
这个函数是 zsh 自带的，有点类似 bash 中的 compgen ，但是功能更加强大。

    '-h::' \
        这里 : 分割的3部分分别是 “待补全的参数:参数的说明:动态补全参数的内容“

根据上面的解释，要想动态补全 -d 参数非常简单，只要加个函数，并配置在 -d:: 之后即可

    #compdef cli-test.sh
    _cli_test() {

        _arguments -C -s -S \
                '-h::' \
                '-u::' \
                '-d:auto complete date:__complete_d_option' \
                '-p::'
    }

    __complete_d_option() {
        local expl
        dates=( `generate_date` )

        _wanted dates expl date compadd $* - $dates
    }

    generate_date() {
        date -v -3d +"%Y-%m-%d"
        date -v -2d +"%Y-%m-%d"
        date -v -1d +"%Y-%m-%d"
        date +"%Y-%m-%d"
        date -v +1d +"%Y-%m-%d"
        date -v +2d +"%Y-%m-%d"
        date -v +3d +"%Y-%m-%d"
    }

    _cli_test "$@"

测试动态补全的效果

    $ ./cli-test.sh -u -d 2016-10-<TAB><TAB>
    2016-10-14  2016-10-15  2016-10-16  2016-10-17  2016-10-18  2016-10-19  2016-10-20