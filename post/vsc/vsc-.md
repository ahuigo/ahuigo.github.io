---
title: vscode 笔记
date: 2018-01-03
---
# vscode
cmd+p

    ?   help
    @{symbol} jump to symbol 
    cmd+shift+m 切换问题面板
    cmd+j 切换集成终端(ctrl+`)
        ctrl+shift+`

## Setting sync
1. Upload Key : Shift + Alt + U
2. Download Key : Shift + Alt + D

## config
1. org scope 分为：user - workspace - directory
2. language scope: 

    "[javascript]": {
        "editor.tabSize": 2
    }

# Emmet
div.test>h3.title+ul>li*3>span.text

## Snippet
Select `User snippets` under:  `Code > Preferences`

Sinippet 转义:
http://codepen.io/mrmlnc/pen/GqrqPg

snippets 的在键入prefix 后，用`Ctrl+Space` 触发

# extension
1. markdown all in one: ctrl+B
2. Paste Image
    "pasteImage.basePath": "${projectRoot}/img",
    "pasteImage.path": "${projectRoot}/img",
    选择文件名 Cmd+Alt+V

# Directory Manager
## New File
 Hit `cmd+shift+p` type `key` a

    ```json
    { "key": "cmd+n", "command": "explorer.newFile", "when": "explorerViewletFocus" }
    ```

# Shortcuts
cmd+k cmd+s: keybindings.json

## Navigation

    ctrl+- / ctrl+shift+- Go back/forward
    ⌘T Show all Symbols
    ⌃G Go to Line...
    ⌘P Go to File...
    ⇧⌘O Go to Symbol...
    ⇧⌘M Show Problems panel
    F8 / ⇧F8 Go to next/previous error or warning

# File 
## Edit

    ⌘X Cut line (empty selection)
    ⌘C Copy line (empty selection)
    ⌥↓ / ⌥↑ Move line down/up
    ⇧⌥↓ / ⇧⌥↑ Copy line down/up

comment

    ```yaml
    ⌘/ Toggle line comment
    ⇧⌥A Toggle block comment
    ⌥Z Toggle word wrap

    ⌘K ⌘C Add line comment
    ⌘K ⌘U Remove line comment
    ```

### Insert tab character manually
    ```json
    { "key": "ctrl+v tab", "command": "type", "args": { "text": "\t" }, "when": "editorTextFocus" }
    ```

## search
cmd+f   search in file
cmd+shift+f search in project
cmd+g/ cmd+shift+g  next/previous matched

## Multi-cursor and selection
```yaml
⌥ + click Insert cursor
⌥⌘↑ Insert cursor above
⌥⌘↓ Insert cursor below
⌘U Undo last cursor operation
⇧⌥I Insert cursor at end of each line selected
⌘I Select current line
⇧⌘L Select all occurrences of current selection
⌘F2 Select all occurrences of current word
⌃⇧⌘→ / ← Expand / shrink selection
⇧⌥ + drag mouse Column (box) selection
```

# Display
cmd+K Z Zen Mode (Esc Esc to exit)

    ```yaml
    ⌃⌘F Toggle full screen
    ⌥⌘1 Toggle editor layout (horizontal/vertical)
    ⌘= / ⇧⌘- Zoom in/out
    ⌘B Toggle Sidebar visibility
    ⇧⌘E Show Explorer / Toggle focus
    ⇧⌘F Show Search
    ⌃⇧G Show Source Control
    ⇧⌘D Show Debug
    ⇧⌘X Show Extensions
    ⇧⌘H Replace in files
    ⇧⌘J Toggle Search details
    ⇧⌘U Show Output panel
    ⇧⌘V Open Markdown preview
    ⌘K V Open Markdown preview to the side
    ```

## window
    打开一个新窗口： Cmd+Shift+N
    关闭窗口： Cmd+Shift+W

## Editor Group
Drag and Drop editor groups: with mouse

    toggle Group Focus(num): cmd+1/2/3
    toggle Group Focus(direction): ⌘K ⌘← / ⌘K ⌘→ 
    ⌘K ← / ⌘K → Move active editor group
    Split Eidtor: cmd+\
    Toggle Editor Group Layout in menu View: Alt+CMD+1

## tabs: File manage
switch tab and project: cmd+shift+e

    ctrl+1/2/3
        toggle Tabs: 
    shift+cmd+[/]
        loop   Tabs: 
    ⌃Tab / ⌃⇧Tab , gt/gT
        navigate tabs: 
    move Tab: 
        ⌘K ⇧⌘← / ⌘K ⇧⌘→ 
    Toggle Tab moves focus: ⌃⇧M 

## file manage
    ```yaml
    ⌘K P Copy path of active file
    ⌘K R Reveal active file in Explorer
    ⌘K O Show active file in new window/instance
    ```

# vim

    gd F12 
         Go to definition 
    Ctrl+-, Ctrl+Shift+- 
        forward/backword
    cmd+/ 
        comment

## vim key remapping
> see github notes!

use `cmd+,` open user settings, the keybindings blew act as `:imap jj <Esc>` 

    "vim.insertModeKeyBindings": [
        {
            "before": ["j", "j"],
            "after": ["<esc>"]
        }
    ]

We can custom readline key bindings:

```json
{
    "vim.enableNeovim": true,
    "vim.insertModeKeyBindingsNonRecursive": [
        { "before": ["<C-f>"], "after": ["<Right>"]},
        {"before": ["<C-a>"], "after": ["<C-o>","0"]},
        {"before": ["<C-u>"], "after": ["<Esc>","c","0"]}
    ],
    "vim.handleKeys": {
        "<C-e>": false
    },
    "workbench.editor.enablePreview": false,
    "python.pythonPath": "python3",
    "python.linting.flake8Enabled": true,
    "workbench.editor.showTabs": true
}
```