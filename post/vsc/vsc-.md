# vscode
cmd+p
cmd+shift+p

# extension
1. markdown all in one: ctrl+B
2. Paste Image
    "pasteImage.basePath": "${projectRoot}/img",
    "pasteImage.path": "${projectRoot}/img",
    选择文件名 Cmd+Alt+V

# Directory Manager
## New File
Add a new file under the selected working directory
1. Hit `cmd+shift+p` type `key` and hit enter on *Preferences: Open Keyboard Shortcuts File*
2. If you want to only have this apply when the explorer is focused you can add a when condition:
```json
{ "key": "cmd+n", "command": "explorer.newFile", "when": "explorerViewletFocus" }
```

# Shortcuts
cmd+k cmd+s: keybindings.json
refer: https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf

## Navigation
⌃- / ⌃⇧- Go back/forward
⌘T Show all Symbols
⌃G Go to Line...
⌘P Go to File...
⇧⌘O Go to Symbol...
⇧⌘M Show Problems panel
F8 / ⇧F8 Go to next/previous error or warning

# File 
## Edit
```yaml
⌘X Cut line (empty selection)
⌘C Copy line (empty selection)
⌥↓ / ⌥↑ Move line down/up
⇧⌥↓ / ⇧⌥↑ Copy line down/up
```
comment
```yaml
⌘K ⌘C Add line comment
⌘K ⌘U Remove line comment
⌘/ Toggle line comment
⇧⌥A Toggle block comment
⌥Z Toggle word wrap
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
⌘K Z Zen Mode (Esc Esc to exit)
```

## window
打开一个新窗口： Cmd+Shift+N
关闭窗口： Cmd+Shift+W

## Editor Group
toggle Group Focus(num): cmd+1/2/3
toggle Group Focus(direction): ⌘K ⌘← / ⌘K ⌘→ 
⌘K ← / ⌘K → Move active editor group
Split Eidtor: cmd+\

Drag and Drop editor groups: with mouse

Toggle Editor Group Layout in menu View: Alt+CMD+1

## tabs: File manage
toggle Tabs: ctrl+1/2/3
loop   Tabs: shift+cmd+[/]
navigate tabs: ⌃Tab / ⌃⇧Tab 
move Tab: ⌘K ⇧⌘← / ⌘K ⇧⌘→ 
Toggle Tab moves focus: ⌃⇧M 

switch tab and project: cmd+shift+e

## file manage
```yaml
⌘K P Copy path of active file
⌘K R Reveal active file in Explorer
⌘K O Show active file in new window/instance
```


## open terminal
ctrl+`
ctrl+shift+`

# vim
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
    "vim.insertModeKeyBindingsNonRecursive": [
        { "before": ["<C-f>"], "after": ["<Right>"]},
        {"before": ["<C-a>"], "after": ["<C-o>","0"]},
        {"before": ["<C-e>"], "after": ["<C-o>","$"]}
        {"before": ["<C-u>"], "after": ["<Esc","c","0"]}
    ]
```
instead of above,  delegate them back to VSCode so that VSCodeVim does not process them.
```json
    "vim.handleKeys": {
        "<C-f>": false,
        "<C-a>": false,
        "<C-e>": false
    }
```

## show tabs
```json
{
    "vim.disableAnnoyingNeovimMessage": true,
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