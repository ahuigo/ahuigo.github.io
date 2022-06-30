---
title: shell ipython
date: 2022-06-29
private: true
---
# shell ipython
Refer to https://jakevdp.github.io/PythonDataScienceHandbook/01.05-ipython-and-shell-commands.html
You can use ipyhon as shell

## shell commond

    In [4]: contents = !ls

    In [5]: print(contents)
    ['myproject.txt']

    In [6]: directory = !pwd

    In [7]: print(directory)
    ['/Users/jakevdp/notebooks/tmp/myproject']

## pass data to shell 
    In [9]: message = "hello from Python"

    In [10]: !echo {message}
    hello from Python

## source shell(%)

    In [14]: %cd ..
    /home/jake/projects
    # In fact, by default you can even use this without the % sign:
    In [15]: cd myproject
    /home/jake/projects/myproject

Besides %cd, other available shell-like magic functions are %cat, %cp, %env, %ls, %man, %mkdir, %more, %mv, %pwd, %rm, and %rmdir, any of which can be used without the % sign if automagic is on. This makes it so that you can almost treat the IPython prompt as if it's a normal shell:

    In [16]: mkdir tmp

    In [17]: ls
    myproject.txt  tmp/

    In [18]: cp myproject.txt tmp/

    In [19]: ls tmp
    myproject.txt

    In [20]: rm -r tmp