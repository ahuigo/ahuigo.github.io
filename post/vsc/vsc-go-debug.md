---
title: Vscode go debug
date: 2020-03-16
private: true
---
# Vscode go debug
## hot reload
https://github.com/cosmtrek/air
有了Hot Reload 功能, 就可以方便Go source 代码修改后，实时重新编译并加载。这方面比较方便的工具是air

配置文件 .air.conf, 在里面写好你好触发的编译命令和可执行文件：

    cmd = "go build -o ./tmp/main cmd/main.go"
    bin = "tmp/main"

执行:

    $ air -c .air.conf

## delve 版本太低 
vscode有可能提示delve 版本太低，可以升级下

    go get -u github.com/go-delve/delve/cmd/dlv
    sudo /usr/sbin/DevToolsSecurity -enable

## 单步调试
按 Shift+Command+X 安装好golang 插件：go

按 Shift+Command+D 切换到调试边栏 为项目添加调试配置, 选择Go: Launch file, 填写配置项目，确定好入口文件: main.go

    {
        "version": "0.2.0",
        "configurations": [
            
            {
                "name": "Launch file",
                "type": "go",
                "request": "launch",
                "mode": "auto",
                "program": "${workspaceFolder}/cmd/main.go",
                "args": [],
                "showLog": true
            }
        ]
    }

然后设置好断点，按F5 启动程序(main.go)进行调试
我们也可以设置断点的条件，比如key="store"

按F5执行程序，当程序达到断点触发的条件后，就可以看到断点处的环境变量、调用栈。


### 注意，对于web server 来说：

    如果断点设置在server 启动阶段，则每次启动server 才能触发断点。
    如果断点设置在 请求响应阶段（比如service），则发送请求后才能触发断点。