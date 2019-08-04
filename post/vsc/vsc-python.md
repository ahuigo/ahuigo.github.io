---
title: Vsc for python
date: 2018-10-04
---
# Vsc for python
https://code.visualstudio.com/docs/python/python-tutorial

## go to denifition
1. 安装python extension (go to definition)
    2. `shift+cmd+p` using the `Python: Select Interpreter` command on the `Command Palette (⇧⌘P)`, 
    2. brew install ctags #go to definition(不需要了)
2. python for vscode (给一些错误tips)

注意：
1. golang 的项目必须放在GOPATH/src 下面才能用go to definition. (软连接也不行！)
2. 本地的包，应该创建touch __init__.py

## Navigation
    F12 Go to definition
    ⌃- / ⌃⇧- Go back/forward
    cmd+j toggle panel (cmd+`)