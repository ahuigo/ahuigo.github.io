---
title: grep & ag 的使用
date: 2018-09-27
---
# grep & ag 的使用
# ag
ag 比ack/grep 还快

    brew install the_silver_searcher

## 自动忽略`.gitinore/.hgignore` 中的文件
https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage
ag 支持`.ignore/.gitinore/.hgignore`

1. Patterns with Single asterisks `*` must be prefixed with a leading `/`. Example:
    Wrong: `my-folder/*/vendor/*`
    Good: `/my-folder/*/vendor/*`
1. Currently double asterisks` **` patterns in `.gitignore and .hgignore and .ignore` are not recognized
    2. 只能用`node_modules` 代替
2. 其它规则跟git 一样

If you want a global `.ignore` file:

    alias ag='ag --path-to-ignore ~/.ignore'

## ag 一般操作

    ag  foo /bar/ ;

    # ignore case
    ag -i foo /bar/ ;

    # word match
    ag -w foo /bar/ ;

    # invert match
    ag -v foo /bar/

其它的，类似grep

    # filename only -l
    ag foo /bar/ -l

## ag regex

    echo abc1234 |ag 'abc\d{3}$'

## ag escape string
    ag  -F -- '->>'

## ag AB
ag after before 不会重复输出：

    ag getsizeof . -A 3 -B 3

# grep

	grep [-acinv] [--color=auto] [--] 'pattern' filename
	选项与参数：
	-x : whole line
	-a ：将 binary 文件以 text 文件的方式搜寻数据
	-c ：计算找到 '搜寻字符串' 的行数
	-i ：忽略大小写的不同，所以大小写视为相同
	-I : ingore binary file
	-n ：顺便输出行号
	-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行！
	-V : version
	-F : 不解释pattern, pattern作为固定的字符串
	-f patterns-file
	-l, --files-with-matches(相当于-m 1 -H)
		 Only the names of files containing selected lines are written to standard output.  grep will only search a file until a match has been found, making searches potentially less expensive.
     -m NUM, --max-count=NUM
          Stop  reading  a  file after NUM matching lines.
	-L, --files-without-match
	-o : 只输出匹配字符串
	--include=PATTERN     Recurse in directories only searching file matching PATTERN.
	--exclude=PATTERN     Recurse in directories skip file matching PATTERN.
    --exclude-dir=PATTERN
	--color=auto ：可以将找到的关键词部分加上颜色的显示喔！

	-h, --no-filename
	-H, --with-filename
	-E, --extended-regexp
	-e 'pattern1' -e pattern2
	-P perl patterns

## -c wc -l

    grep -P pattern | wc -l
    grep -Pc pattern

## max-count

	-m max-count 匹配次数

## other grep:

	fgrep
		grep -F
	rgrep
		grep -r
	agrep
		approximate grep
	zgrep
		grep compress file

## grep binary

	-I
       ignore binary
    -a, --text
       Process a binary file as if it  were  text

## grep context

	-C num context num
		-C 2  The default is 2 and is equivalent to -A 2 -B 2

## grep filter self
Refer to: [](/p/shell)

Remove grep command while use ps

	ps aux | grep perl | grep -v grep
	ps aux | grep [p]erl

## exclude file & dir

	--exclude=\*.{html,htm,js}
    grep -R --exclude-dir=node_modules 'some pattern' /path/to/search

## multi patterns

	-e 'pattern1' -e pattern2
	-f pattern.txt

If you want to do the minimal amount of work, change

	grep -o -P 'PATTERN' file.txt

to

	perl -nle'print $& if m{PATTERN}' file.txt

So you get:

	var1=`perl -nle'print $& if m{(?<=<st:italic>).*(?=</italic>)}' file.txt`
	var2=`perl -nle'print $& if m{(property:)\K.*\d+(?=end)}' file.txt`

However, you can achieve simpler code with extra work.

	var1=`perl -nle'print $1 if m{<st:italic>(.*)</italic>}' file.txt`
	var2=`perl -nle'print $1 if /property:(.*\d+)end/' file.txt`

> $print $& 打印全部匹配到的字段,  而print $1而为打印第一个括号

## print the filename only

	-L, --files-without-match
		Only the names of files not containing selected lines are written to standard output.  Pathnames are listed once per file searched.  If the standard input is searched, the string ``(standard input)'' is written.

	-l, --files-with-matches
		Only the names of files containing selected lines are written to standard output.  grep will only search a file until a match has been found, making searches potentially less expensive.  Pathnames are listed once per file searched.  If the standard input is searched, the string ``(standard input)'' is written.