---
title: Vim Guide
date: 2019-05-29
---
# Vim Guide
学习VIM 的步骤
1. 初始VIM 基本操作，在bash 输入： `$ vimtutor`
2. 系统学习VIM: learn vim the hard way
    1. 前半部分是重点、核心
    2. 后半部分涉及插件，属于扩展
3. 反复总结、熟悉。本文件就是对VIM 的总结

# Motion/Movement，光标移动
Normal mode 移动

    基本 hjkl
    单词 
        小单词wbe
            w: word forward
            b: word backward
            e: end of word
        大单词WBE​
    行
        行头: 
            0
            ^
        行尾: $
        跳行：
            100G
            :100
    块
        [( ])  ​
        [{ ]}​
    页
        页内移动： H:Home M:middle L:Last 
                扩展知识： J:Concat Line K:Manual​
        半页<C-u> <C-d>​
        全页<C-f> <C-b>​ (这两个键 已经被我用Readline 占用了)
    全文：
        首行: gg
        尾行: G
    匹配移动：
        %

Insert/Command mode 移动​, 只需要加前缀`<C-o>`

    <C-o> + hjkl
    <C-o> + wbeWBE

一般`<C-o>` 是要结合map 做成方便的快捷键的, 比如在`~/.vimrc` 加入

    " Go to head of line
    imap <C-a> <C-o>0

    " Go to end of line
    imap <C-e> <C-o>$

# TextObject, 操作对象
掌握

    [count] + Action + TextObject

查看帮助：

    :help motion
    :h motion

## Action, 动作 
Action 分：
1. Delete: `d`
2. Copy: `y`
3. Paste: `p`
4. Change(等价于Delete+Insert): `c` 
4. Visual: `v`
4. lowercase/upercase: 
    4. gU(改大写): `gu`
    4. gu(改小写): `gU`

## TextObject, 操作对象
TextObject 与Motion 的区别
1. motion 可以不用Action, 指 **指光标移动所经过的字符** （我觉得motion 是一种不需要action 的textObject）
    1. hjkl
    2. wbe WBE
    3. .....
2. TextObject(必须要Action)
    1. 比如 `Delete` + `inner word`: `diw`
    1. 比如 `Delete` + `a block`: `da{`
    1. 比如 `Copy` + `a block`: `ya{`

常用的TextObject

    词: iw aw iW aW (i: 不含空白或边界)
    句: is as
    块: 
        i( a( 
        i[ a[
        i{ a{

## Action+TextObject
掌握语法

    [count] + Action + TextObject/Motion

Example1: Delete word

        dw
        diw

Example2: Delete inner block

        di(
        ci(

Example3: 

    3dw


重复的Action 默认当前行为TextObject

    dd
    gugu

# Open and Close, 打开关闭文件
## 打开:
1. 读文件: vi test.csv
    1. 打开100行: `vi test.csv +100`
1. 读管道:
    1. `curl 'http://baidu.com' | head -5 | vim -`
1. 编辑当前的命令行: `Ctrl+x Ctrl+e`
    1. 你需要设置: `echo 'export EDITOR=vim'>>~/.zshrc`
2. vim 内再打开其它的文件：
    1. 打开 `:e other.html`
    1. 重命名当行文件`:f rename.html`

## 关闭
1. 保存退出: `ZZ` is better than `:wq`
1. 不保存退出: `ZQ` is better than `:q!`

# Visual 模式
[Visual 模式](/p/vim/vim-visual)

# Repeat, 重复

## count+Action重复


    100l 右移100次
    3dw
    3dd
    3<<

## . 操作重复
重复的. 操作

    .....

## C+v, 列重复

## macro, 宏重复

	q{register}命令是启动宏录制的
        q 是结束宏录制的
	@{register}是使用宏的
	要说明的是这个register：
	1．　这个register与yank(复制)是共用的，能相互影响
	2．　大写的register，会往register中追加数据，如qC、"Cy会旆c寄存器中追加数据．
