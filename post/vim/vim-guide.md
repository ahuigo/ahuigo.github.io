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
[Normal mode 移动](/p/vim/vim-motion)

# Open and Close, 打开关闭文件
## 打开
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
`.` 用于重复上次的操作

    .....

## C+v, 列重复

## macro, 宏重复

	q{register}命令是启动宏录制的
        q 是结束宏录制的
	@{register}是使用宏的
	要说明的是这个register：
	1．　这个register与yank(复制)是共用的，能相互影响
	2．　大写的register，会往register中追加数据，如qC、"Cy会旆c寄存器中追加数据．

# 编辑
[编辑操作](/p/vim/vim-edit)