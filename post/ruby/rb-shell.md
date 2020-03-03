---
title: Ruby shell
date: 2019-02-17
private:
---
# exec ruby
    -a	与 -n 或 -p 一起使用时，可以打开自动拆分模式(auto split mode)。请查看 -n 和 -p 选项。
    -c	只检查语法，不执行程序。
    -C dir	在执行前改变目录（等价于 -X）。
    -d	启用调试模式（等价于 -debug）。


    ruby -e 'printf "sss"' a.rb
# exec shell

## 跳脱符(php like)
类似php

    # 打印并返回raw字符串
    p `ls -la *`

    # escapes newline chars
    printf `ls -la`

支持`*`

    printf `ls *`

exec with variable

    cmd = "ls #{ENV['HOME']}/www"
    `echo #{cmd}`

## system
只支持参数, 没有返回数据, 不支持`*`

    # 只返回true/false(like python: os.system)
    system "ls", "-la"

    # wrong *
    system "ls", "*"
    # ok
    printf `ls -la *`
