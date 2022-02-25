---
title: mac 的open 命令
date: 2022-02-24
private: true
---
# mac 的open 命令

## open file/dir
    # finder
    open dir

    # open any file 
    open file

## open vscode

    code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
    code .

或者用官方自带的`code`

# click path
vscode 支持 click path in terminal and open it in vsocde

    press CMD + SHIFT + P
    type 'shell command' 
    select 'Install code command in path'
    navigate to any project from the terminal and type 'code .'
