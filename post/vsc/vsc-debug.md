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
      "type": "node",
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

### Global launch
> Tip: If a workspace contains a `"launch.json"`, the global launch configuration is ignored.
VS Code supports adding a "launch" object inside your User settings. 

    "launch": {
        "version": "0.2.0",
        "configurations": [{
            "type": "node",
            "request": "launch",
            "name": "Launch Program",
            "program": "${file}"
        }]
    }

### launch runtime
    "runtimeExecutable": "/opt/homebrew/bin/deno",
    "runtimeArgs": [ "run", "--config", "./deno.dev.json",]

## Variable substitution

    "args": ["${env:USERNAME}"]
    "cwd": "${workspaceFolder}",
     "runtimeArgs": [ "run", "-A",]

### platfrom special properties
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

# Advanced breakpoint topics
> Some debugger does not support conditional/inline breakpoints. 
> Different languages need different debugger, install by menu: `Run->install additional debugger`

## stop on entry

      "stopOnEntry": true,
      "osx": {
        "stopOnEntry": false
      }

## Conditional breakpoints
> https://code.visualstudio.com/docs/editor/debugging#_advanced-breakpoint-topics
conditions based on expressions, hit counts, or a combination of both.

1. `Expression condition`: The breakpoint will be hit whenever the expression evaluates to true.
2. `Hit count`: The 'hit count' controls how many times a breakpoint needs to be hit before it will 'break' execution. Whether a 'hit count' is respected and the exact syntax of the expression vary among debugger extensions.

## Inline breakpoints
This is particularly useful when debugging minified code which contains multiple statements in a single line.

An inline breakpoint can be set using `⇧F9` or through the context menu during a debug session. Inline breakpoints are shown inline in the editor.

## Function breakpoints
This is useful in situations where source is not available but a function name is known.

A function breakpoint is created by pressing the `+` button in the `BREAKPOINTS section header` and entering the function name. Function breakpoints are shown with a red triangle in the BREAKPOINTS section.

![](/img/vsc/debug-breakpoint-func.png)

## Data breakpoints
If a debugger supports data breakpoints they can be set from the `VARIABLES view` and will get hit when the value of the underlying variable changes. Data breakpoints are shown with a red hexagon in the **BREAKPOINTS section**.

# Debug Console REPL
Debug Console command (`⇧⌘Y`). Expressions are evaluated after you press Enter and the Debug Console REPL shows suggestions as you type. 

If you need to enter multiple lines, use `Shift+Enter` between the lines and then send all lines for evaluation with Enter. 

Debug Console input uses the mode of the active editor, which means that the Debug Console input supports syntax coloring, indentation, auto closing of quotes, and other language features.

# Redirect input/output to/from the debug target
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

# Remote debugging
VS Code does not itself support remote debugging: this is a feature of the debug extension you are using, and you should consult the extension's page in the [Marketplace](https://marketplace.visualstudio.com/search?target=VSCode&category=Debuggers&sortBy=Downloads) for support and details.

There is, however, one exception: the `Node.js debugger` included in VS Code supports remote debugging. See the Node.js Debugging topic to learn how to configure thi

# Automatically open a URI when debugging a server program#
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

# 各语言的调试方法
vsc-go-debug

# 通用debug
https://github.com/redhat-developer/vscode-java/wiki/Troubleshooting#enable-logging

## 显示console log
Open the command palette (F1)
1. select `Developer: Toggle Developer Tools`

## vscode version
    # 可参考a/tool/os/os-info.py
    code -v


