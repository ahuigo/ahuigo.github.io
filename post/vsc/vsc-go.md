---
title: Vscode golang
date: 2020-03-16
private: true
---
# IntelliSense
## Auto completions
vsc settings.json:

    go.autocompleteUnimportedPackages: true

Tip: Use `⌃Space` to trigger the suggestions manually.

## Hover Information#
By default, the extension uses `godef and godoc` to get this information. 

You can choose to use `gogetdoc` instead by changing the setting `go.docsTool` in your User or Workspace Settings.

## Signature help
Tip: Use `⇧⌘Space` to manually trigger the signature help when the cursor is inside the `()` in the function call.
 ![](/img/vsc/go-signature-help.png)

By default, the extension also uses `godef and godoc` to get signature information. 

# Code navigation
Code navigation features are available in the context menu in the editor.

1. Go To Definition `F12` - Go to the source code of the type definition.
1. Peek Definition `⌥F12` - Bring up a Peek window with the type definition.
1. Go to References `⇧F12` - Show all references for the type.

You can navigate via symbol search using the Go to Symbol commands from the Command Palette (⇧⌘P).

1. Go to Symbol in File - `⇧⌘O`
1. Go to Symbol in Workspace - `⌘T`

# Build, lint, and vet
On save, You can control these features via the settings below:

    go.buildOnSave
    go.buildFlags
    go.vetOnSave
    go.vetFlags
    go.lintOnSave
    go.lintFlags
    go.lintTool
    go.testOnSave

The errors and warnings from running any/all of the above will be shown red/green squiggly lines in the editor. These diagnostics also show up in the **Problems panel (View > Problems)**

## Formatting
You can format your Go file using `⇧⌥F`

By default, formatting is run when you save your Go file. You can disable this behavior by setting:

    "[go]":  {
        "editor.formatOnSave": false
    }

You can choose among three formatting tools: `gofmt`, `goreturns`, and `goimports` by changing the setting `go.formatTool`.

## Test
There are many test-related commands that you can explore by typing "`Go: test`" in the Command Palette.
Test Commands
![](/img/vsc/go-test.png)

1. The first three above can be used to **generate test skeletons** for the functions in the current package, file or at cursor using gotests. 

2. The last few can be used to **run tests** in the current package, file or at cursor using go test. There is also a command for getting test coverage


# Vscode go debug
## hot reload
https://github.com/cosmtrek/air
有了Hot Reload 功能, 就可以方便Go source 代码修改后，实时重新编译并加载。这方面比较方便的工具是air

配置文件 .air.conf, 在里面写好你好触发的编译命令和可执行文件：

    cmd = "rm ./tmp/main;go build -o ./tmp/main cmd/main.go"
    bin = "tmp/main"

或

    full_bin = "MONGODB_HOST=127.0.0.1:27017 MONGODB_USER=test MONGODB_PASSWORD=test REDIS_ADDR=127.0.0.1 GIN_MODE=debug go run *.go"

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

### debug console 
在debug console 中, 可以直接输入变量观察

    > somevar
    "world"
    > string(somebytes)


### 注意，对于web server 来说：

    如果断点设置在server 启动阶段，则每次启动server 才能触发断点。
    如果断点设置在 请求响应阶段（比如service），则发送请求后才能触发断点。

