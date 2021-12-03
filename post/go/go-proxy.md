---
title: go 国内访问
date: 2020-07-29
private: 
---
# go 国内访问
> 原文作者：Summer
> 转自链接：https://learnku.com/go/wikis/38122
> 版权声明：著作权归作者所有。商业转载请联系作者获得授权，非商业转载请保留以上作者信息和原文链接。

Go 生态系统中有着许多中国 Gopher 们无法获取的模块，比如最著名的 golang.org/x/...。

## goproxy
以下是几个速度不错的GOPROXY提供者：

    官方： < 全球 CDN 加速 https://goproxy.io/>
    七牛：Goproxy 中国 https://goproxy.cn
    其他：jfrog 维护 https://gocenter.io
    阿里： https://mirrors.aliyun.com/goproxy/

## 设置代理
### 类 Unix
在 Linux 或 macOS 上面，需要运行下面命令（或者，可以把以下命令写到 .bashrc 或 .bash_profile 文件中）：

    # 启用 Go Modules 功能
    go env -w GO111MODULE=on

    # 配置 GOPROXY 环境变量，以下三选一

    # 1. 官方
    go env -w  GOPROXY=https://goproxy.io

    # 2. 七牛 CDN
    go env -w  GOPROXY=https://goproxy.cn

    # 3. 阿里云
    go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/
    确认一下：

    $ go env | grep GOPROXY
    GOPROXY="https://goproxy.io"
### Windows
在 Windows 上，需要运行下面命令：

    # 启用 Go Modules 功能
    $env:GO111MODULE="on"

    # 配置 GOPROXY 环境变量，以下三选一，首推阿里云

    # 1. 阿里云
    $env:GOPROXY="https://mirrors.aliyun.com/goproxy/"

    # 2. 官方
    $env:GOPROXY="https://goproxy.io"

    # 3. 七牛 CDN
    $env:GOPROXY="https://goproxy.cn"

## 测试一下
    $ time go get golang.org/x/tour

## 缓存清理 
本地如果有模块缓存，可以使用命令清空 
go clean --modcache 

## 私有模块
如果你使用的 Go 版本 >=1.13, 你可以通过设置 GOPRIVATE 环境变量来控制哪些私有仓库和依赖 (公司内部仓库) 不通过 proxy 来拉取，直接走本地，设置如下：

    # Go version >= 1.13
    go env -w GOPROXY=https://goproxy.io,direct
    # 设置不走 proxy 的私有仓库，多个用逗号相隔
    go env -w GOPRIVATE=*.corp.example.com

# jfrog
jfrog-cli 是 artifactory提供的工具，可用来上传、管理各种包

## jfrog syntax
https://www.jfrog.com/confluence/display/CLI/JFrog+CLI#JFrogCLI-Syntax

    $ jfrog rt go-publish -h  
    $ jfrog target command-name [global-options] [command-options] arguments
    target
        The product on which you wish to execute the command:
        rt: Artifactory
        xr: Xray
        ds: Distribution
        mc: Mission Control

    command-name
        The command to execute. Note that you can use either the full command name or its abbreviation.

    global-options
        A set of global options specifying the product URL and means of authentication. These may be used for all commands

    command-options
        A set of options corresponding to the command

    arguments
        A set of arguments corresponding to the command
