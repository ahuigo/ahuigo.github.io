---
title: path
date: 2018-10-04
---
# path
Available variables which can be used inside of strings.

    // ${workspaceRoot}: the root folder of the project, not workspace 一般跟${cwd} 一样. 我的是www/proj

        // ${file}: the current opened file
        // ${fileBasename}: the current opened file's basename
        // ${fileDirname}: the current opened file's dirname
        // ${fileExtname}: the current opened file's extension
        // ${cwd}: the current working directory of the spawned process

按快捷键`cmd+,`, 在配置中搜索`full path`
active file: window.showFullPath: true

    // ${activeEditorShort}: e.g. myFile.txt
    // ${activeEditorMedium}: e.g. myFolder/myFile.txt
    // ${activeEditorLong}: e.g. /Users/Development/myProject/myFolder/myFile.txt
    // ${rootName}: e.g. myProject
    // ${rootPath}: e.g. /Users/Development/myProject
    // ${appName}: e.g. VS Code

directory:

    workspaceFolder
    workspaceRoot


