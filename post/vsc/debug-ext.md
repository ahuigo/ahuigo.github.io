---
title: Vsc dev
date: 2019-11-12
private: true
---
# Vsc dev

## meta 信息
    a/tool/os/os-info.py
## install from vsix

    code --install-extension myextension.vsix

# debug extension
## 断点调试
https://code.visualstudio.com/api/get-started/your-first-extension
1.　add breakpoint
2. F5

## extension logs
1. 在`Output`栏，查看 log(Window)
1. 在`Output`栏，查看 log(main)

### write log
    //Create output channel
    let orange = vscode.window.createOutputChannel("Orange");

    //Write to output.
    orange.appendLine("I am a banana.");

## java extension debug
https://github.com/redhat-developer/vscode-java/wiki/Troubleshooting#enable-logging

    java.trace.server configuration can be set to verbose

## chrome dev tools
When the Java extension fails to start, the first thing to look at is the VS Code console.

    Open the command palette (F1)
    select Developer: Toggle Developer Tools

# 性能问题分析

## 查找有问题的插件
第一种方法，比较准确的方法是使用`> Start Extension Bisect`

    使用二分的方法，每一步选择good/bad,

第二种方法，使用命令`> show running extensions`就能看到正在运行的插件，其中的profile 最大的就可能是有问题的

## main+插件进程cpu/mem 占用
vscode 按`Cmd+p`,　输入命令`> Open Process Explorer`可查看main+plugin进程占用

