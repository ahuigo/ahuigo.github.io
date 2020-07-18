---
title: Xargs
date: 2019-08-18
private:
---
# xargs
shell 中很多命令都是支持read from stdin的。 对于不支持stdin 的ls 可以使用xargs

	xargs [-0Epn] command
	 -0      Change xargs to expect NUL (``\0'') characters as separators, instead of spaces and newlines.  This is expected to be used in concert with the -print0 function in find(1).

     -E eofstr
             Use eofstr as a logical EOF marker.
	 -p      Echo each command to be executed
	 -n number
		 use number of parameter in each exec command
	 -J replstr
		 Replacing one or more occurrences of replstr in up to replacements arguments
		 The replstr must show up as a distinct argument to xargs
	 -I replstr
		Replacing one or more occurrences of replstr in up to replacements arguments
	 -t
	 	Echo the command to be executed to standard error immediately before it is executed.

Example:

	echo -e "string1\x00string2\x00end\x00string3"| xargs -0p -E'end' echo
	ls | grep .php$ | xargs -n 1 php -l
	# Use "%" as a variable that store parameter
	ls | grep .php$ | xargs -n 1 -J % mv % dst/
	xargs -n 1 -J % -I % echo cp -r % ../v4_feed/%

	cut -d':' -f1 /etc/passwd |head -n 3| xargs finger
	cut -d':' -f1 /etc/passwd |head -n 3| xargs -p -n 2 finger #每个命令执行时都需要提示.
	cut -d':' -f1 /etc/passwd |head -n 3| xargs -p -n 2 -E 'root' finger #见到root 后截止

> xargs 可以用于不支持管道的命令, 比如ls. 有的命令可通过参数"-"支持管道, 就不需要xargs 了
> 当 xargs 后面没有接任何的命令时，默认是以 echo 来进行输出喔！

## xargs eval
eval is a shell builtin command, not a standalone executable. Thus, xargs can't run it directly. You probably want:

	ls -1 | gawk '{print "`mv "$0" "tolower($0)"`"}' | xargs -t sh -c "eval {}"
	sh -c "$cmd" '2nd,3rd,.. args is ignored'

## 分割符
    -L number
        Call utility for every number non-empty lines read. 
        The -L and -n options are mutually-exclusive; the last one given will be used.
    -n number
        默认 -n 5000
        Call utility for every number non-empty token from standard input.

默认是spaces/newlines 做分割的

    $ echo "one two three\nabc" | xargs -p -n1 echo
    echo one?...
    echo two?...
    echo three?...
    echo abc?...

按行分割

    $ echo "one two three\nabc" | xargs  -p -L1 echo
    echo one two three?...
    echo abc?...

按null 分割(不分)

	 -0      Change xargs to expect NUL (``\0'') characters as separators, instead of spaces and newlines.  This is expected to be used in concert with the -print0 function in find(1).


## 进程限制
xargs默认只用一个进程执行命令。如果命令要执行多次，必须等上一次执行完，才能执行下一次。
1. --max-procs参数指定同时用多少个进程并行执行命令。
2. --max-procs 2表示同时最多使用两个进程，

--max-procs 0表示不限制进程数。

    $ docker ps -q | xargs -n 1 --max-procs 0 docker kill