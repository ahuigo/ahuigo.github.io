---
title: find dir of command
date: 2018-09-27
---
# find dir of command

    which lshw
    which -a lshw
    type -a lshw
    whereis lshw

find realpath:

    readlink -f $(which lshw)

# check if command exists
Don't use `which`, because it  doesn't even set an exit status in some OS .

Use instead the following:

    $ command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
    $ type foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
    $ hash foo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }