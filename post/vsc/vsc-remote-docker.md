---
title: vscode remote docker
date: 2020-06-02
private: true
---
# vscode remote docker
## 基于image 打开一个已经存在的项目
`cmd+p` 打开`Remote-Containers: Open Folder in Container...`

## mount
单个mount:

    "workspaceMount": "source=/home/ahuigo/proj,target=/usr/src/app,type=bind,consistency=delegated", 
    "workspaceFolder": "/usr/src/app"

`"mounts"` 可支持多个mount