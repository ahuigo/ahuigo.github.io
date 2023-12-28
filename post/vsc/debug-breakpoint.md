---
private: true
---
# Advanced breakpoint topics
https://code.visualstudio.com/docs/editor/debugging#_launch-configurations

> Some debugger does not support conditional/inline breakpoints. 
> Different languages need different debugger, install by menu: `Run->install additional debugger`

## stop on entry

    // .vscode/launch.json
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
