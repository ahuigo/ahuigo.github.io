---
title: vscode remote docker
date: 2020-06-02
private: true
---
# vscode dev container
> 安装vscode Dev Containers
## 启动
### 基于container 
几种方法：
- `cmd+p` 打开`Dev Containers: Reopen in Container...`
- `cmd+p` 打开`Dev Containers: Open Folder in Container...`
- 或者连接到运行中的容器** 使用 Dev Containers: Attach Visual Studio Code **

## mount
配置单个mount:
```
    "image": "golang:1.22",
	"workspaceFolder": "/user/src/app",
    "workspaceMount": "source=/home/ahuigo/proj,target=/usr/src/app,type=bind,consistency=delegated", 
    "workspaceFolder": "/usr/src/app"
```
`"mounts"` 可支持多个mount

> 在Ubuntu系统中，由于运行docker需要root权限。本地调用vscode的docker插件无法获取镜像文件，需要将本地用户加入到docker的组中，使用非root的方式运行： https://docs.docker.com/engine/install/linux-postinstall/
