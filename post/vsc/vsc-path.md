---
title: path
date: 2018-10-04
---
# path
https://code.visualstudio.com/docs/editor/variables-reference

Available variables which can be used inside of strings.

    ${workspaceFolder} - the path of the folder opened in VS Code
    ${workspaceFolderBasename} - the name of the folder opened in VS Code without any slashes (/)
    ${file} - the current opened file
    ${relativeFile} - the current opened file relative to workspaceFolder
    ${relativeFileDirname} - the current opened file's dirname relative to workspaceFolder
    ${fileBasename} - the current opened file's basename
    ${fileBasenameNoExtension} - the current opened file's basename with no file extension
    ${fileDirname} - the current opened file's dirname
    ${fileExtname} - the current opened file's extension
    ${cwd} - the task runner's current working directory on startup
    ${lineNumber} - the current selected line number in the active file
    ${selectedText} - the current selected text in the active file
    ${execPath} - the path to the running VS Code executable
    ${defaultBuildTask} - the name of the default build task



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


