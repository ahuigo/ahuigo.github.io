---
title: go module workspace
date: 2023-02-23
private: 
---
# go 本地模块支持
参考go-pkg-tidy.md 我们引用本地包可以这样

    require (
        github.com/ahuigo/requests v0.0.0
    )
    replace (
        github.com/ahuigo/requests v0.0.0 => ../requests
    )

这种方式replace依赖本地文件系统的路径。不是太通用。此时可以用go1.18的workspace
# workspace
## 多目录管理
假设我们目录结构, proj1, proj2 都依赖requests, fx两个module

    ./work/
        ./proj1
        ./proj2
        ./requests
        ./fx

那么只需要按以下操作，就可以直接require fx 和requests了（不需要入侵改代码）

    $ cd work 
    $ go work init requests fx
    $ cat go.work
    go 1.19
    use (
        ./requests
        ./fx
    )

也可添加

    go work use ./fx
    go work use requests

注意，如果项目本身要独立运行main 或 go test, 目录本身也要设定为 项目

    go work use .
    # 或一次加全
    go work init requests fx .

## 单module
    /proj1/
        /requests
    /fx

如果我们只想为proj1建立一个工作区

    $ cd proj1
    $ go work init ../fx requests
    $ cat go.work
    go 1.19
    use (
        ../fx
        ./requests
    )

## pkg/v2
比如 github.com/ahuigo/requests/v2 的这个包的根目录文件中存在

    // proj/response.go
    package requests

我们不能改写成 package v2, 但是我们可以设定工作区

    requests $ go work init .
