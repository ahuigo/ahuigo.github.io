---
title: go embed
date: 2021-11-20
private: true
---
# go embed
Go 1.16 is the support for **embedding files and folders into the application binary** at compile-time without using an external tool. 

## embed FS
参考go-lib/cicd/embed/embed.go 编译时将resouce 目录打包里res 变量

    //go:embed resource
    res embed.FS

也可以指定多个文件

    //go:embed resource/index.html go.mod readme.md

## embed single file
    //go:embed resource/index.html
    s string

## Limitations
embed 目前不能打包
1. empty folder
2. 以`.`或`_`开头的文件/目录
3. symlink file
