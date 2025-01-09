---
title: vscode sync
date: 2021-11-20
private: true
---
# vscode sync
在左下角设备旁点用户，点Setting Sync.

可以选择vscode.github.com 或者 microtsoft 两种平台会配置备份与同步

## 备份

    # 1. 备份＋清理
    mv ~/Library/Application\ Support/{Code,code2}
    # 备份扩展清单
    ls ~/.vscode/extensions/ > ~/vsc.extension-list.txt
    # 清理所有的扩展
    rm -rf ~/.vscode/extensions/

    # 2. 卸载、重装vscode+扩展
    略

    # 3. 只还原了User下的：keybindings.json, settings.json, snippets
    mv ~/Library/Application\ Support/code2/User/{{settings,keybindings}.json,snippets}  ~/Library/Application\ Support/Code/User/

## extension

```
$ ls ~/.vscode/extensions
alefragnani.project-manager-12.7.0
bradlc.vscode-tailwindcss-0.12.15
codeium.codeium-1.2.76
denoland.vscode-deno-3.42.0
donjayamanne.githistory-0.6.20
esbenp.prettier-vscode-9.10.4
extensions.json
github.copilot-1.243.0
github.copilot-chat-0.22.4
github.copilot-chat-0.23.1
github.vscode-pull-request-github-0.78.1
golang.go-0.42.1
hbenl.vscode-mocha-test-adapter-2.14.1
hbenl.vscode-test-explorer-2.21.1
intellsmi.comment-translate-2.3.2
mhutchie.git-graph-1.30.0
ms-python.debugpy-2024.0.0-darwin-arm64
ms-python.python-2024.2.1
ms-python.vscode-pylance-2024.3.2
ms-vscode-remote.remote-containers-0.327.0
ms-vscode-remote.remote-ssh-0.107.1
ms-vscode-remote.remote-ssh-edit-0.86.0
ms-vscode.remote-explorer-0.4.1
ms-vscode.test-adapter-converter-0.1.9
mushan.vscode-paste-image-1.0.4
orangex4.hsnips-0.4.8
orta.vscode-jest-6.2.5
pkief.material-icon-theme-5.11.1
redhat.fabric8-analytics-0.9.4
redhat.java-1.30.0-darwin-arm64
rust-lang.rust-analyzer-0.3.1850-darwin-arm64
sastan.twind-intellisense-0.2.1
vadimcn.vscode-lldb-1.10.0
vscjava.vscode-java-debug-0.57.0
vscjava.vscode-java-dependency-0.23.6
vscjava.vscode-java-pack-0.26.0
vscjava.vscode-java-test-0.40.1
vscjava.vscode-lombok-1.1.0
vscjava.vscode-maven-0.44.0
vscodevim.vim-1.28.1
waderyan.gitblame-11.1.1
yzane.markdown-pdf-1.5.0
yzhang.markdown-all-in-one-3.5.1
```
