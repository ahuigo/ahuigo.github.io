---
title: vscode remote docker
date: 2020-06-02
private: true
---
# vscode remote docker
## 启动
### 基于container 
`cmd+p` 打开`Dev Containers: Open Folder in Container...`


## mount
配置单个mount:

    "workspaceMount": "source=/home/ahuigo/proj,target=/usr/src/app,type=bind,consistency=delegated", 
    "workspaceFolder": "/usr/src/app"

`"mounts"` 可支持多个mount


> 在Ubuntu系统中，由于运行docker需要root权限。本地调用vscode的docker插件无法获取镜像文件，需要将本地用户加入到docker的组中，使用非root的方式运行： 
> https://docs.docker.com/engine/install/linux-postinstall/
