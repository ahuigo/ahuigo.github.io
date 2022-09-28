---
title: vim global
date: 2022-09-27
private: true
---
# vim global

    :[range]g[lobal]/{pattern}/{command}
    :[range]v[global]/{pattern}/[cmd] "reverse
        same as :g!

在 range 范围内匹配 patter 的行执行 Ex command。所有的 Ex command 可以使用 :help ex-cmd 来查看

## move
将所有匹配的行移动到文件第一行（倒序）

    :g/^/m 0

    ^ 
        mark all line
    m 0
        move to first line

将所有匹配的行移动到文件的末尾

    :g/pattern/m$

## range
    :g/{from_pattern}/,/{end_pattern}/{command}

匹配并删除，但是不包括最后一行

    :g/DESCRIPTION/,/PARAMETERS/-1d

比如以下命令，将在包含“microsoft antitrust”的前2行以及后2行中进行替换：
http://yyq123.github.io/learn-vim/learn-vim-GlobalCommand.html

    :g/microsoft antitrust/-2,/microsoft antitrust/+2s/judgment/ripoff/c

将以下文本中的“SYNTAX”部分，移到“PARAMETERS”之前：

    :g /SYNTAX/.,/DESCRIPTION/-1 move /PARAMETERS/-1
    :g /SYNTAX/,/DESCRIPTION/-1 move /PARAMETERS/-1
    # SYNTAX
    ....
    # DESCRIPTION
    desc1...
    desc2...

    # PARAMETERS
    param ...

## copy
    qaq:g/pattern/y A

    qaq 清空寄存器 a，qa 开始记录命令到a寄存器，q 停止记录
    y A 将匹配的行 A (append) 追加到寄存器 a 中

## delete
删除所有空行：

    :g/^$/d

删除偶数行

    :g/^/+1 d
    +1 下一行（就是偶数行）

Vim 在删除操作时，会先把要删除的内容放到寄存器中，避免花费不必要的时间可以指定一个 blackhole 寄存器 `_`

    :g/pattern/d_

## search replace
在匹配行后添加文字

    :g/pattern/s/$/mytext

vglobal 实现 将aaa替换成bbb，除非该行中有ccc或者ddd

    :v/ccc\|ddd/s/aaa/bbb/g
    :g!/ccc\|ddd/s/aaa/bbb/g

## if
global 实现的: 匹配aaa并满足行内有ccc但不能有ddd

    :g/ccc/if getline('.') !~ 'ddd' | s/aaa/bbb/g

每10行删除前/后3行

## let
计算文件中数字列之和

    :let i=0
    :g/^/let i+=str2nr(getline('.'))
    :echo i

## print
查找并显示文件中所有包含模式pattern的行：

    :g/pattern/p

# reference
https://einverne.github.io/post/2017/10/vim-global.html