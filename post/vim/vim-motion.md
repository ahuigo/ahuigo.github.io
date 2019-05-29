---
layout: page
title:	vim-motion
category: blog
description:
---
# Motion, Movement
Movement 移动光标、字符，Vim 最核心的功能操作

## move cursor光标移动
以下归纳的是按光标移动(Normal/Visual模式下). 如果需要在insert mode下移动光标, 需要加一个前缀键: Ctrl+o

    #在insert mode下光标左移一个字符
    Ctrl+o h  "相当于按<Left>
    Ctrl+o A	"移动到开头
    #在insert mode下光标左移后退一个大单词
    Ctrl+o B sfsadfadfs在

## 常用的(motion)
motion 指移动光标、字符

    hjklwbeWBE

### 按字符移动光标hjkl

    几乎所有的移动都可以在前面加数字——实现重复的动作

注意一下大小写, 大写的HJKLM与小写的含义迥然不同:

    H:Home M:middle L:Last J:Concat Line K:Manual

#### move cursor in insert mode / insert模式下的hjkl
建议做一个键映射

    cnoremap <C-a> <Home>
    cnoremap <C-e> <End>

ps:如果要实现跨行移动,需要在`.vimrc`指定相应键：

    set whichwrap=b,s,<,>,[,]

    b 在 Normal 或 Visual 模式下按删除(Backspace)键。
    s 在 Normal 或 Visual 模式下按空格键。
    h 在 Normal 或 Visual 模式下按 h 键。
    l 在 Normal 或 Visual 模式下按 l 键。
    < 在 Normal 或 Visual 模式下按左方向键。
    > 在 Normal 或 Visual 模式下按右方向键。
    ~ 在 Normal 模式下按 ~ 键(翻转当前字母大小写)。
    [ 在 Insert 或 Replace 模式下按左方向键。
    ] 在 Insert 或 Replace 模式下按右方向键。

### move cursor by word 按单词移动光标

    w 下一词首 b上一词首 e下一词尾
    WBE 大写则表示将特殊符号（非空白）也作为单词的一部分

    * "移动到下一个单词，这个单词与光标下的单词是一样的
    # "移动到上一个单词，这个单词与光标下的单词是一样的

#### insert mode
如果需要在insert mode 下做单词移动, 可以这样子

    "linux
    :inoremap <A-b> <C-o>b
    :inoremap <A-f> <C-o>w
    "mac
    :inoremap ∫ <C-o>b
    :inoremap ƒ <C-o>w

很遗憾, mac Terminal vim 下的alt+left/right 不支持光标移动. 而且不能做map映射

    <shift>+Left/Right
    <ctrl>+Left/Right

### 按行移动光标

    0行首第一字符
    ^行首第一非空字符

    $ 行尾
    g_ To the last non-blank character of the line

    :line_num 移动到指定行号
    <line_num>G 移动到指定行号

#### insert mode

    :inoremap <C-j> <down>

### move cursor by fold
[vim-fold](/p/vim-fold)

    zj/zk "move to next/previous fold
    [z  "move to the begining of fold
    ]z  "move to the end of fold

### screen motion - 按屏幕移动光标

    <C-U> 上半屏幕
    <C-D> 下半屏幕
    <C-B> 上一屏幕
    <C-F> 下一屏幕
    H 屏幕首行
    M 屏幕中部
    L 屏幕尾部

    <C-Y> 上滚屏幕一行
    <C-E> 下滚屏幕一行
    zt or z<CR> 光标回到top (前者保留光标column)
    zz or z. 光标回到中部 (前者保留光标column)
    zb or z- 光标回到bottom (前者保留光标column)
    z<height><CR> 设置屏幕的高度
    ps:以上均可跟用数字控制(仅M忽略数字)

### object motion - 按括号对()[]{}移动光标

## 字符移动(charactor move)

### 左右缩进(indent)

    >> << 左右缩进 你可以用sw(shiftwidth)控制缩进长度
    ctrl-t,ctrl-d 左右缩进(insert mode)

### 自动缩进（autoindent）
实现开始新行时，实施上一行缩进

    :set autoindent :set ai

### 移动字符(move)

    :[range]m {address} "address是目的地址

global 与move 结合会收到强大的效果，比如：

    :g/^/m 0 #执行过程是，/^/会匹配所有的行，包括空行。然后把每一行放到第一行之上（即0行）这样就完成了全文件倒序
    :'t+1,.g/^/m 't #结果是把t+1移动到't之下，再把't+2行移到到't行之下，直到.
    :h :m "寻求帮助


## 行范围(range)

    :% 全文件
    :. 当前行
    :.+{offset} 当前行+行偏移
    :$+{offset} 最后一行+行偏移
    :<num> 第num行
    :'t "标记t所指明的行
    :/pattern/{offset} 第一个正向匹配到的行+偏移
    :?pattern?{offset} 第一个反向匹配到的行+偏移
    :start,end 第start到end行
    :?starword?,/endword/ "匹配起止
    :'t,'m "标记起止
    visual块(其实是标记:'<,'>)

eg:

    :% !wc 统计文件的行数 单词数 字节数(结果会替换当前范围)

## :g命令(:g)
usage:

    :[range]g[lobal]/{pattern}/[cmd]
    :g/insert into/y A "复制所有带insert into的行到寄存器A中
    :g/^/m 0 "倒序

与:g对应的还有个反向的:v, 相当于`:g!` 不匹配的行才执行cmd

    :[range]v[global]/{pattern}/[cmd]

## argdo/bufdo

    "将要扫描的文件加入argument list (filelist)
    :args **/*.txt **/*.cpp

    :argdo[!] {cmd}         Execute {cmd} for each file in the argument list.(作用于文件列表)
    :bufdo[!] {cmd}         Execute {cmd} in each buffer in the buffer list.
    :windo[!] {cmd}         Execute {cmd} in each window


如果你想把当前目录下（包括子文件夹）所有后缀为 java 的文件中的 apache 替换成 eclipse，那么依次执行如下命令(copy from 池建强)： 在当前目录下执行：

    vim
    :n **/*.java
    :argdo %s/apache/eclipse/ge | update

这用到了buffer 的概念，通过正则表达式在内存中打开多个文件，
argdo 表示在内存中执行 Vim 的命令，
%s/apache/eclipse/ge 表示在内存中执行字符串替换，g 表示全局替换，e 表示如果文件中没有可替换字符串不报错继续执行,
`|` 是管道标识符，update 表示替换完之后更新并写入文件。


# motion,movement
移动范围

    2dd 删除两行
    2>> 移动两行

# insert

    gI		Insert in column 1

# line

    . current line
    + next line
    +4 next 4'th line

# marks
marks 不是保存在register 中的，这个注意一下

    m{mark}
    :marks				list all marks
    :delm[arks]	{mark}	  safd del mark

## mark list

    '{A-Z0-9}  	全局标记
    '{a-z}  	buffer marks

Last jump

    '' `` `'	上一标记(latest jump, toggle)
    '" 			To the position when last existing the current buffer(需要开启对.viminfo信息支持)

modified && insert stop && changed

    '. 			To the position the latest modified.
    '^  `^		To the position where the cursor was the last time when Insert mode was stopped.
                This is used by the |gi| command.
    `[  `]		To the first/last character of the previously changed or yanked text.

Visual mode

    '<			The first character of the last selected Visual area in the current buffer.
    '>			The last character of the last selected Visual area in the current buffer.

sentence

    '( ')		To the start/end of current sentence
    '{ '}		To the start/end of current paragraph

## make marks

    m{mark}

## jump mark

    `{mark}		jump to pos defined by mark
    '{mark}		jump to the line head of pos defined by mark

    '{a-z}  `{a-z}
            Jump to the mark {a-z} in the current buffer.
            with sigle quote, jump to the begining of the line

    '{A-Z0-9}  `{A-Z0-9}
            To the mark {A-Z0-9} in the file where it was set (not
                a motion command when in another file). global

    g'{mark}  g`{mark}
                Jump to the {mark}, but don't change the jumplist when
                jumping within the current buffer.

# jumplist, jumps
A "jump" is one of the following commands:

    "'", "`", "G", "/", "?", "n", "N", "%", "(", ")", "[[", "]]", "{", "}", ":s", ":tag", "L", "M", "H"
    and the commands that start editing a new file.

If you make the cursor "jump" with one of these commands, the position of the cursor before the jump is
remembered.

    ctrl-o 跳到旧的jump (jump backward in insert & normal mode)
    ctrl-i/<TAB> 跳到新的jump (jump forward in normal mode)
    :ju or :jumps 查看jumplist（曾经跳过的位置列表）
    :help jumplist 查帮助

ps: <C-O> 或者 <C-I>/<TAB> 前面都可加数字(jumpid),比如

    3<C-O>
    5<C-I> or 5<TAB>

# change list

    :help changelist
    :changes 	print all change list

    g; "跳到上次修改
    g, "跳到新的修改
    `. "跳到上次修改

# text object, 文本对象
text object 分两种：
1. 移动光标的: hjklwbeWBE
2. 不能移动光标的：iw,aw,a{,i{

本节包含的是不能移动光标的：

    aw iw "a word & a inner word后者不包含空白
    aW iW "a word 大写的字符表示特殊字符是单词的一部分
    as is "a sentence	后者不含空白及换行
    ap ip "a prograph
    a'
    a{

    "当光标在( ), [ ],< >, { }, " ", '' 内时
    "括号内
    i( or i)
    "中括号内
    i[ or i]
    i{ or i}
    "引号内
    i" i'

Tag object

    i> i< a> a<
        "<> block"

    at it
        "a tag block" like "<div> use `dat` <span> to delete div</span> </div>"

Block Motion

    aB a{
        {}
    2aB 2a{
        {{}}

    ab a(
    2ab 2a(

文件对象与操作结合：

    daw "delete a word
    cis "replece a sentence
    yi{ "yank all contents between left { and right }

    va(
    va[
    va{

### 设定单词key

    :set iskeyword=@,48-57,192-255,-,_ "@代表英文字母
    :set iskeyword-=_ #从单词key中删除下划线
