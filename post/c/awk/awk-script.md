---
title: awk script
date: 2024-09-30
private: true
---
# awk script

## 执行多个脚本
	 awk -f my.awk file - arg1 arg2
	 cat my.awk
	 	BEGIN { FS=":" } { print $1 }

包含多个脚本:

    gawk -i lib1.awk  -i lib2.awk -f main.awk

## pretty_print script

    gawk -o- <(cat a.awk)

    -o 或 --pretty-print 参数用于生成一个格式化的版本的 AWK 程序，并将其输出到指定的文件
    -o- 表示输出到标准输出

## call bash shell
awk 中使用shell 命令

	"shell_cmd1"|"shell_cmd2"; //return output of cmd2
	"shell_cmd1"|awk_cmd;

Example:

	awk 'BEGIN{print "abc"|"grep c"}'

	"shell_cmd" | getline;//no output
	("shell_cmd" | getline);//1: succ 0:failed(getline will not run)
	system(shell_cmd);//0:succ, not 0:failed

或者使用system 开启shell 子进程

	awk 'BEGIN{system("echo abc | grep c")}'

system, 成功返回0，失败返回非0(如127)

### shell pipe
    cmd="wc -l"
    text="1\n2\n"
    print(text) | cmd

	while ((HttpService |& getline) > 0) {

	}

    print(header "\r\n") |& HttpService


#### close pipe
get output from shell command

	cmd = "ls -l"
	while ( ( cmd | getline result ) > 0 ) {
	  print  result
	}
	close(cmd); # close pipe or file

Closing Input and Output Redirections(Pipe) via `close(cmd)`

## pipe 文件
### read file
使用getline 命令 读重定向

	awk 'BEGIN{while(getline<"date.txt"){print $0}}' #$0 可省略

使用getline 命令 读取管道定向的流, 成功返回1, 失败返回0
读取第一行

	awk 'BEGIN{"cat a.txt"|getline line; print line}'
	awk 'BEGIN{"cat date.txt"|getline; print $0}'

### write file
> shell 原生命令`split -l<line_count> -a <suffix_num> -d prefix`

按第6列拆分文件:

	$ awk 'NR!=1{print > $6}' netstat.txt #$6 是文件名

指定列

	$ awk 'NR!=1{print $4,$5 > $6}' netstat.txt; # > 其实是append