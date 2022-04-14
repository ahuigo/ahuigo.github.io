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
## extension logs
1. 在`Output`栏，查看 log(Window)
1. 在`Output`栏，查看 log(main)

## java extension debug
https://github.com/redhat-developer/vscode-java/wiki/Troubleshooting#enable-logging

    java.trace.server configuration can be set to verbose

## chrome dev tools
When the Java extension fails to start, the first thing to look at is the VS Code console.

    Open the command palette (F1)
    select Developer: Toggle Developer Tools
