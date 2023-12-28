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

# cpu/mem 占用
## 进程占用process explorer
vscode 按`Cmd+p`,　输入命令`> Open Process Explorer`可查看main+plugin进程占用
