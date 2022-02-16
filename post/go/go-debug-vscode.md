---
title: Golang： debuging & Live Reload with docker
date: 2020-04-01
private: true
---
# debug： vscode + hotReload + docker + dlv
> refer1:livereload https://medium.com/@hananrok/debugging-hot-reloading-go-app-within-docker-container-b44d2929e8bd
> refer2:vscode https://bloggie.io/@_ChristineOo/debugging-go-with-delve-and-vscode
> vscode+go debug: https://github.com/Microsoft/vscode-go/wiki/Debugging-Go-code-using-VS-Code

code example: go-lib/go-debug/remote-dlv/main.go

## 利用ionotify+目录挂载实现livereload
首先将当前的源码映射到一个目录，如/build 或/app/src：

    docker run --rm --name server8 -v $PWD:/build -p8080:8080 -p2345:2345 delve-docker-vscode-example

再利用sh run.sh 写一个liverreload 脚本

## 利用delve 进行debugger
Delve is full featured debugging tool for Go. 

    go get github.com/go-delve/delve/cmd/dlv

### dlv 可执行文件
想使用delve, 需要编译支持：

    # cgo 关闭动态态链接
    ENV CGO_ENABLED 0

    # 加:`-N -l` 去掉optimiztion 和inlining 内联
    RUN go -gcflags "all=-N -l" build -o /server main.go

然后使用delve 开一个监听

    dlv --listen=:2345 --headless=true --api-version=2 exec ./server
    dlv --listen=:2345 --headless=true --api-version=2 --log exec ./server
    dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./server

### dev debug .go

    dlv debug --headless --listen=:2345 --api-version=2 --log main.go

## 利用docker 执行
本例我们使用docker执行 dlv:

    docker run --rm --name server8 -v $$PWD:/build -p8080:8080 -p2345:2345 --security-opt=seccomp:unconfined delve-docker-vscode-example
    API server listening at: [::]:2345

`--security-opt=seccomp:unconfined` 是必须的, 因为:

    Docker has security settings preventing ptrace(2) operations by default with in the container. Pass --security-opt=seccomp:unconfined

如果是在docker-compose.yml 中执行参考：https://github.com/christineoo/go-delve-docker-vscode-example/blob/master/docker-compose.yml

    services:
      web:
        container_name: go-delve-docker-vscode-example
        build: "./"
        ports:
          - "8080:8080"
          - "2345:2345"
        security_opt:
          - "seccomp:unconfined"
        tty: true
        stdin_open: true
        command: dlv debug --headless --listen=:2345 --api-version=2 --log main.go

## vscode 连接delve
配置dlv: localhost:2345, 指定`remotePath:"/go/src"`

    launch.json
    {
      "version": "0.2.0",
      "configurations": [
        {
          "name": "Launch",
          "type": "go",
          "request": "launch",
          "mode": "remote",
          "program": "${workspaceFolder}", //本地源
          "remotePath": "/go/src",
          "port": 2345,
          "env": {},
          "args": [],
          "showLog": true,
          "trace": "verbose"
        }
      ]
    }
### 单步
启动项目执行断点
1. vscode: main.go 加断点
2. 启动docker 或 docker-compose 或者纯dlv
3. vscode: F5启用 Debug: start
4. 访问8080 服务

切换到Debug Console: 可执行函数调用，输出变量值
    > string("abc")
    "abc"
    > string(string(output))
    "hello"


# debug simple main package
配置：

    {
        "name": "Launch Package",
        "type": "go",
        "request": "launch",
        "mode": "auto",
        "program": "${fileDirname}"
    }

F5 运行后vscode自动监听62324：

    dlv dap --check-go-version=false --listen=127.0.0.1:62324 --log-dest=3 /home/user/proj/cmd/server -- arg1 arg2

# dlv remote 
https://github.com/golang/vscode-go/blob/master/docs/debugging.md#remote-debugging

    dlv debug /path/to/program/ --headless --listen=:12345 # also add as needed: --accept-multiclient --continue

    dlv debug --headless --listen=:12345 --api-version=2 --log main.go -- arg1 arg2
    dlv debug --headless --listen=:12345 --api-version=2 --log /path/to/package

conf:

    {
        "name": "Connect to external session",
        "type": "go",
        "debugAdapter": "dlv-dap", // `legacy` by default
        "request": "attach",
        "mode": "remote",
        "port": 12345,
        "host": "127.0.0.1", // can skip for localhost
        "substitutePath": [
        { "from": ${workspaceFolder}, "to": "/path/to/remote/workspace" },
        ...
        ]
    }


# debug running process
https://medium.com/average-coder/how-to-debug-a-running-go-app-with-vscode-76e3eac45bd

## 1.run go app

    go build -o /path/to/my-hello-world cmd/main.go
    /path/to/my-hello-world

## 2.dlv go process
    dlv attach --headless --listen=:2345 $(pgrep my-hello-world) /path/to/package -- arg1 arg2

## 3.config vscode
        {
            "name": "Launch",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "remotePath": "",
            "port": 2345,
            "host": "127.0.0.1",
            // "remotePath": "${workspaceFolder}",
            "program": "${fileDirname}",
            "env": {},
            "args": [],
            "showLog": false
        }


# test
## test env 配置
  "go.testEnvVars": {
        "xx": "yy" //示例
    }
