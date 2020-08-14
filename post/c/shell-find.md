---
layout: page
title: ops-find
category: blog
description: 
date: 2018-09-27
---
# Preface

	find -maxdepth 1 -name '*' -inum 1324 -exec rm {} \;
	find -maxdepth 1 -name '*' -inum 1324 -exec mv {} {}.txt \;
	//Note! There is a space before terminating ";" or "+"
	find . -name .DS_Store -exec rm {} +
	//du -d 1

# 输出控制
    #-print 将查找到的文件输出到标准输出
    #-false 将查找到的文件输出到标准输出
    #-exec   command {} \;   将查到的文件执行command操作
    #-ok command {} \; 和-exec相同，但是在操作前要询用户

## print

    # 默认会输出./demo
    $ find . -path ./demo -prune  -o  -name '*'
    ./demo

    # 有了-print, 默认就不输出了
    $ find . -path ./demo -prune  -o  -name '*' -print

    # 全部加print 才能全部输出
    $ find . -path ./demo -prune -print -o  -name '*' -print
    ./demo

# depth

	find . -maxdepth 1 -name '*' -inum 1324 -exec rm {} \;
    # 只搜索指定层级
	find . -depth 1 -name '*' -inum 1324 -exec rm {} \;

# -iname
case insensitive

	-iname '*abc*'

# -perm 属性过滤

	754(rwxr-xr--) a.txt
	find . -perm 755 # 755 == 754 false
	find . -perm +4000 # 4000 & 0754 true
	find . -perm -4000 # (4000 & 0754) == 4000 false
	find . \(! -perm -0754 -o -perm 766 \)

# -user

	fond  -user uname
	fond  ! -user uname

# date

## atime
最近第7天被访问过的所有文件:

	find . -atime -7 -type f -print

查询7天前被访问过的所有文件:

	find . -atime +7 type f -print

## mtime
最近1天修改

    find /directory_path -mtime -1 -ls
    find /<directory> -newermt "1 day ago" -ls

最近120min:

    -mmin -120

# size
按大小搜索： w字 k M G 寻找大于2k的文件:

	find . -type f -size +2k

# after action
找到后的后续动作

删除当前目录下所有的swp文件:

	find . -type f -name "*.swp" -delete
	find . -type f -name "*.swp" -exec rm {} \;
	find . type f -name "*.swp" | xargs rm

# Logic Operators
The primaries may be combined using the following operators.  The operators are listed in order of decreasing precedence.

     ( expression )
             This evaluates to true if the parenthesized expression evaluates to true.

     ! expression
     -not expression
             This is the unary NOT operator.  It evaluates to true if the expression is false.

     -false  Always false.
     -true   Always true.

     expression -and expression
     expression -a expression
     expression expression
             The -and operator is the logical AND operator.  As it is implied by the juxtaposition of two expressions it does not have to be specified.  The expression evaluates to
             true if both expressions are true.  The second expression is not evaluated if the first expression is false.

     expression -or expression
     expression -o expression
             The -or operator is the logical OR operator.  The expression evaluates to true if either the first or the second expression is true.  The second expression is not evaluated if the first expression is true.

For example:

	#! -path exclude dir
	find . -type f -name '*.php' ! -path "./dir1/*" ! -path "./scripts/*"
    find . -type f ! -path '*/.svn*' ! -path '*.git*'
	find . -type f ! -path './[.|nbproject|todo]*'

    ! expr1 expr2
    //equal to
    ( ! expr1 ) expr2
    //not equal to
    ! ( expr1 expr2 )

# inode

	-inum n

# match path

## -regex
支持BRE 正则，和ERE 正则(-E 参数)

	find . -regex ".*/[abc]/.*"
	find -E . -regex ".*/(word1|word2)/.+"

## -path
支持wildcard

	-path pattern
	-path './[dir1|dir2]/*'

## exclude path
`-prune` stops find from descending into a directory(只包括目录名).

	# -prune does not exclude the directory itself but its contents. So you should use `-print` to print
	find . -path ./dir -prune -o -name '*.txt' -print

    # prune multiple directories
	find . \( -path ./dir1 -o -path ./dir2 \) -prune -o -name '*.txt' -print

    # prune with not expression
    find . -type f ! -path '*/.svn*' ! -path '*/.git*'
	find . ! \( \(-path ./dir1 -o path ./dir2 \) -prune \) -name \*.txt

Just specifying `-not -path` cannot stop find from descending into the skipped directory, so `-not -path` will work but it is not the best method:

    "not work
	find . ! -path './dir1/*' -name '*'

## find with sed

    find /home/www -type f -print0 | xargs -0 sed -i 's/subdomainA\.example\.com/subdomainB.example.com/g'

-print0 (GNU find only)

1. tells find to use the null character (\0) instead of whitespace as the output delimiter between pathnames found.
2. Be safe if files can contain blanks or other special character. (the -0 argument is needed in xargs.)

# match file
Match dirname and file via `-name`

	# wildcard only
	find dir1 dir2 -name "*.py"