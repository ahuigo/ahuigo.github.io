---
title: Docker ignore
date: 2020-01-14
private: true
---
# Docker ignore
Refer to:
https://docs.docker.com/engine/reference/builder/#dockerignore-file


    # comment	Ignored.
    */temp*	    Exclude files and directories whose names start with temp in any immediate subdirectory of the root. 
    */*/temp*	Exclude files and directories starting with temp from any subdirectory that is two levels below the root. For example, /somedir/subdir/temporary.txt is excluded.
    temp?	    Exclude files and directories in the root directory whose names are a one-character extension of temp. For example, /tempa and /tempb are excluded.

多级目录

    **/node_modules

子目录

    */*/node_modules