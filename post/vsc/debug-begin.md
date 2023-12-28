---
title: Vsc debug
date: 2020-03-16
private: true
---
# launch.json 配置

## Launch and Attach 两种配置
https://code.visualstudio.com/docs/editor/debugging#_launch-versus-attach-configurations

### program
Launch 是用于server 程序

    {
      "type": "go",
      "request": "launch",
      "name": "Launch Program",
      "program": "${file}"
    }

### attach
 For Chrome DevTools/other running programs, use attaching mode

        {
            "type": "node",
            "request": "attach",
            "name": "attach to Process",
            "port":5858,
        }
        {
            "name": "Attach to Process",
            "type": "go",
            "request": "attach",
            "mode": "local",
            "processId": 18
        }

### Automatically open a URI when debugging a server program#
If we want auto open uri if port 3000 is ready?

    app.listen(3000, function() {
        console.log('Example app listening on port 3000!');
    });

The `serverReadyAction` feature makes it possible to add a structured property serverReadyAction to any launch config and select an "action" to be performed:

    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${workspaceFolder}/app.js",

      "serverReadyAction": {
        "pattern": "listening on port ([0-9]+)", // 会匹配：  console.log('Example app listening on port 3000!');
        "uriFormat": "http://localhost:%s", // %s替换pattern 第一个分组
        "action": "openExternally"
      }
    }


### launch runtime(deno)
    "runtimeExecutable": "/opt/homebrew/bin/deno",
    "runtimeArgs": [ "run", "--config", "./deno.dev.json",]

## Variable substitution
Refer to debug-var.md

    "args": ["${env:USERNAME}"]
    "cwd": "${workspaceFolder}",
     "runtimeArgs": [ "run", "-A",]

## platfrom special properties
Such as windows/osx/linux properties

      "args": ["myFolder/path/app.js"],
      "windows": {
        "args": ["myFolder\\path\\app.js"],
        "env":{},
      }

### args and ENV

      "args": ["-d", "./"],
      "env": {"APP_ENV":"dev"},

### cwd
https://code.visualstudio.com/docs/editor/debugging#_launch-configurations

    "cwd": "${workspaceRoot}",

## Redirect input/output to/from the debug target
Redirecting input/output is debugger/runtime specific, so VS Code does not have a built-in solution that works for all debuggers.

Here are two approaches you might want to consider:

1. Launch the program to debug ("debug target") manually in a terminal or command prompt and redirect input/output as needed. **Create and run an "attach" debug configuration** that attaches to the debug target.

2. If the debugger extension you are using can run the debug target in VS Code's Integrated Terminal (or an external terminal), you can try to pass the shell redirect syntax (for example `"<" or ">"`) as arguments.

Here's an example launch.json configuration:

    {
      "name": "launch program that reads a file from stdin",
      "type": "node",
      "request": "launch",
      "program": "program.js",
      "console": "integratedTerminal",
      "args": ["<", "in.txt"]
    }

# Debug Console REPL
Debug Console panel (`⇧⌘Y`). Expressions are evaluated after you press Enter and the Debug Console REPL shows suggestions as you type. 

If you need to enter multiple lines, use `Shift+Enter` between the lines and then send all lines for evaluation with Enter. 

# Remote debugging
VS Code does not itself support remote debugging: this is a feature of the debug extension you are using, and you should consult the extension's page in the [Marketplace](https://marketplace.visualstudio.com/search?target=VSCode&category=Debuggers&sortBy=Downloads) for support and details.

There is, however, one exception: the `Node.js debugger` included in VS Code supports remote debugging. 

# 调用方法
## go debug
vsc-go-debug.md

## java debug
https://github.com/redhat-developer/vscode-java/wiki/Troubleshooting#enable-logging

## 显示console log
Open the command palette (F1)
1. select `Developer: Toggle Developer Tools`

## vscode version
    # 可参考a/tool/os/os-info.py
    code -v