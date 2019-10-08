---
title: Vsc for python
date: 2018-10-04
---
# Vsc for python
https://code.visualstudio.com/docs/python/python-tutorial

## todo
python in vscode 调试方法
https://www.zhihu.com/question/339718367

## debug
项目根目录下：.vscode/launch.json

    {
        "version": "0.2.0",
        "configurations": [
            {
                // 运行模块 python -m hello
                "name": "Python: 模块",
                "type": "python",
                "request": "launch",
                "module": "hello"
            },
            {
                // 该配置用于运行当前窗口打开的文件 python file.py
                "name": "Python: 文件",
                "type": "python",
                "request": "launch",
                "program": "${file}",
                //"program": "${workspaceRoot}/db/run.py",
            }
        ]
    }

环境变量，与参数设定：

            "env": {
                "FLASK_APP": "app.py",
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "0"
            },
            "args": [
                "run",
                "--no-debugger",
                "--no-reload"
            ],

在调试控制台窗口，有一个python shell 用于观察、修改 局部变量


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