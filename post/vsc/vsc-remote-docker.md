---
title: vscode remote docker
date: 2020-06-02
private: true
---
# vscode remote docker
## mount
单个mount:

    "workspaceMount": "source=/home/ahuigo/proj,target=/usr/src/app,type=bind,consistency=delegated", 
    "workspaceFolder": "/usr/src/app"

`"mounts"` 可支持多个mount