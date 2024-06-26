---
title: rust debug in vscode with sudo
date: 2024-06-18
private: true
---
# rust debug in vscode with sudo
方法多个：https://github.com/microsoft/vscode-cpptools/issues/861
1. alias Sc='sudo code-insiders --user-data-dir="~/.vscode-root"'
2. `"miDebuggerPath": "${workspaceFolder}/.vscode/lldb.sh"`, `echo $'#!/bin/sh\nsudo /usr/bin/lldb $@' > .vscode/lldb.sh`
2. 参考：张逸就是我 链接：https://juejin.cn/post/7162053987615637541

## 采用vscode远程登录的方案
远程连接 就是Remote - SSH
点击左侧远程资源管理器, 选到自己, 连接进去就是root身份了