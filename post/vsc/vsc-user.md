---
title: vsc user
date: 2023-03-19
private: true
---

# github Authentication
许多插件都依赖了vscode github user. 比如：

1. github copilot
1. github settings sync

如果你关闭了github authentiction, 打开方式是：

    OSX:
        Code->Preferences -> Profiles(default) -> Show Profile Contents
        找到 github authentiction， 点enable
    Linux:
        File -> Preferences -> Profiles -> Show Contents
