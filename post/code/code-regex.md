---
title:	Posix Regex 正则语法
date: 2018-08-18
---
# Wildcard 通配符 和 Posix 正则
正则分两大类:Posix和PCRE(Perl Compatible Regular Expression ). posix 已经很老了, 效率也没有PCRE高. 但是它被linux命令行广泛支持.
在介绍Posix Regex之前, 我们先看看wildcard 通配符

# wildcard 通配符

	* 多个字符
	? 单个字符
	\* \? 转义特殊字符
    [...] 字符集合
        [^...]和[!...] 两种写法是等价的。
	[a-z] 字符范围
        [^a-z] 不在此字符范围(unix系统shell)
        [!1-9]
    {abc,def} 字符串集合
        echo {j{p,pe}g,png}
    {a..z} 字符串范围
        echo {10..20}.txt

目录匹配: `*` 不匹配`/`, `*/`匹配单层目录, 但最`**/` 则匹配多层目录

    # 单层目录
    $ ls */*.md |grep s-if
    # 多层目录
    $ ls **/*.md |grep s-if
    eng/s/s-if.md

.gitignore 的特殊性:

    # 不含`/` 则默认为: **/*.log
    *.log

## Mysql 中的wildcard

	%	A substitute for zero or more characters
	_	A substitute for a single character
	\%	\_ Escape special character
	[charlist]	Sets and ranges of characters to match
	[^charlist] or [!charlist]	Matches only a character NOT specified within the brackets

# Regular Expression

## 贪婪

	*?	重复任意次，但尽可能少重复
	+?	重复1次或更多次，但尽可能少重复
	??	重复0次或1次，但尽可能少重复
	{n,m}?	重复n到m次，但尽可能少重复
	{n,}?	重复n次以上，但尽可能少重复

    >> re.search("(switchport)?", " switchport").groups()
    Out[13]: (None,)
    >> re.findall("(switchport)?", " switchport")
    Out[16]: ['', 'switchport', '']

## 0宽度断言
判断密码必须符合至少8个字符、大小写、数字

    //(?=exp)	匹配exp前面的位置
    //(?<=exp)	匹配exp后面的位置
    /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z]{8,}$/
    /^
    (?=.*\d)          // should contain at least one digit 注意不是 (?=\d)
    (?=.*[a-z])       // should contain at least one lower case
    (?=.*[A-Z])       // should contain at least one upper case
    [a-zA-Z0-9]{8,}   // should contain at least 8 from the mentioned characters
    $/


# Posix Expression
POSIX正则表达式分为：BRE (Basic Regular Expression) 和 ERE (Extended Regular Expressions)。

BRE 并非是ERE的子集.以下是它们的交集:

	\ 用于关闭后续字符的特殊意义。
	\r\n 回车换行
	\n 对子模式的反引用(backreference) 支持\1到\9
	. 匹配任意单个的字符
	* 匹配任意数目的字符(可以为0)
	^ 匹配出现在行首或字符串开始位置的空字符串。ERE：置于任何位置都具特殊含义；BRE：仅在正则表达式的开头具有此特殊含义。
	$ 匹配出现在行末的空字符串。
	[...] 元字符 比如:
		[a-z] [^1-9]
		[[:space:]] 空白符	也相当于perl中的\s
		[^[:space:]] 非空白符	也相当于perl中的\S
		[[:alnum:]] same as [a-zA-Z0-9]
		[[:digit:]] same as [0-9] 也相当于perl中的\d
		[[:xdigit:]] same as [0-9a-fA-F]
		[[:alpha:]] same as [a-zA-Z]
		[[:upper:]] same as [A-Z]
		[[:lower:]] same as [a-z]
		[[:punct:]] Punctuation Characters
		[[:<:]] 匹配单词的开始 	perl中的\b代表单词边界
		[[:>:]] 匹配单词的结束
		[:graph:] Characters that are printable and are also visible. (A space is printable, but not visible, while an `a' is both.)

	\w
		a short-hand for [[:alnum:]]
	\W
		The oppsite of `\w`
	\<
		Matches the beginning of word
	\>
		Matches the endding of word
	\b
		Matches the either beginning or end of word(`\b` means `backspace` in awk, so awk uses `\y` instead)
	\B
		The oppsite of `\b` (`\y`)

`*` 共有的， 0个或以上元字符或子模式

    *? 去贪婪(不生效)

## BRE 专有

	\{n,m\} \{n,\} 限制它之前的元字符或者子模式重现的次数区间
	\( \) 子模式
	\| 或
    \+

## ERE 专有

    {n,m}
    ? 0/1个元字符或子模式
    + 1个或多个元字符或子模式
		+? 去贪婪(不生效)
    | 或
    () 子模式
	^ 行首
	$ 行尾
	\num 反引用
	[^]]
		不要用转义[^\]]

Example:

    echo -n ' ./alxxxxal 1.txt' | grep -E './(al).+\1'
    $ echo -n $'ba123' | gsed -nr '/ba?123/p'
    ba123%

ERE,BRE 都不支持：

	(?:expr) 非捕获
	.*?		非贪婪不生效

# PCRE

## comment
注释

	(?#comment)	这种类型的分组不对正则表达式的处理产生任何影响，用于提供注释让人阅读

## 断言

	(?=exp) 也叫零宽度正预测先行断言，它断言自身出现的位置的后面能匹配表达式exp。
		比如\b\w+(?=ing\b)，匹配以ing结尾的单词的前面部分(除了ing以外的部分)，
	(?<=exp)也叫零宽度正回顾后发断言，它断言自身出现的位置的前面能匹配表达式exp。
		比如(?<=\bre)\w+\b会匹配以re开头的单词的后半部分(除了re以外的部分)
	(?!exp)，零宽度负预测先行断言, 断言此位置的后面不能匹配表达式exp。
		例如：\d{3}(?!\d)匹配三位数字，而且这三位数字的后面不能是数字
	(?<!exp), 零宽度负回顾后发断言>
		(?<![a-z])\d{7} 匹配前面不是小写字母的七位数字>
	(?(exp)yes|no)	把exp当作零宽正向先行断言，如果在这个位置能匹配，使用yes作为此组的表达式；否则使用no

	(?<=exp)word(?=exp)
	(?<!exp)word(?!exp)    # >

# 支持情况
常用命令的支持对wildcard/posix/perl 的支持情况
1. grep 通过`-E` 启用ERE
    2. grep 通过`-P` 启用Perl Regex(gnu grep only)
2. find 同时支持POSIX (`-regex '.*\.txt$'` )正则，以及Wildcard 通配符(`-path '*.txt'`)。
3. sed 通过`-r` 启用ERE
4. gawk 默认ERE

sed/gsed 默认使用BRE, 也支持ERE. 但是*sed* 不支持`\r\n` 

    $ echo -n $'abc\r123' | sed -n '/abc\r123/p'
    $ echo -n $'abc\r123' | gsed -n '/abc\r123/p'
    123%
    $ echo -n $'abc\r123' | sed -n $'/abc\r123/p'
    123%

mac OSX 下的`grep -E` 与GNU 的`grep -P` 是等价的, 你也可以安装GNU grep:

    // /usr/local/bin/grep
    brew install grep

## Reference
- http://www.ruanyifeng.com/blog/2018/09/bash-wildcards.html
