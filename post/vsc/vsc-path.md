---
title: path
date: 2018-10-04
---
# path
Available variables which can be used inside of strings.

    // ${workspaceRoot}: the root folder of the team, not workspace

        // ${file}: the current opened file
        // ${fileBasename}: the current opened file's basename
        // ${fileDirname}: the current opened file's dirname
        // ${fileExtname}: the current opened file's extension
        // ${cwd}: the current working directory of the spawned process

active file: window.showFullPath: true

    // ${activeEditorShort}: e.g. myFile.txt
    // ${activeEditorMedium}: e.g. myFolder/myFile.txt
    // ${activeEditorLong}: e.g. /Users/Development/myProject/myFolder/myFile.txt
    // ${rootName}: e.g. myProject
    // ${rootPath}: e.g. /Users/Development/myProject
    // ${appName}: e.g. VS Code