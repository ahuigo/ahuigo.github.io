---
layout: page
title:	Sed 简记
category: blog
description:
---
# sed 与gsed
grep 与sed 同样是以按行匹配，不过sed 不仅能按行匹配，还能替换字符

>ps: mac 下的sed与linux下的gnu sed有很大的不同，建议安装gsed（如果你熟悉gnu-sed）: brew install gnu-sed

## mac linux sed


### in-place
修改文件要用`-i`

    -i extension (mac sed)
    -i[SUFFIX], --in-place[=SUFFIX] (gsed)
        edit files in place (makes backup if SUFFIX supplied)

mac 使用的是BSD sed, `-i` 参数后必须跟一个扩展名, 如果想直接修改原文件，则扩展名用空字符串:

	sed -i '.ori' $'/^PATH=/c\\\n sth.' a.txt #> a.txt.ori (注意bash的string不直接支持\n, 只能使用$'string\n' , 不是$"string\n"哈, $"string\n"与 "string\n"没有分别) $'\\\n' 会被bash 解析为'\n', '\n' 又被sed 解析为换行
	sed -i '' "/^PATH=/ c\\
	sth." a.txt #> a.txt

而linux下(gnu sed)`-i`与参数要合并,同时`\\\n`,` `,`\\`等换行、空白符、转义符会被忽略

	gsed $'/^PATH=/c\\\n sth.' a.txt > a.txt.ori
	gsed -i $'/^PATH=/c\\\n sth.' a.txt #> a.txt
	gsed -i.ori $'/^PATH=/c\\\n sth.' a.txt #> a.txt

## sed 基本格式
sed 命令行基本格式为:

	sed option 'script' file1 file2 ...
	sed option -f scriptfile file1 file2 ...

基本line语法为:

	/pattern/action
	range{/pattern/action}
	s/pattern/replace/g
	s#pattern#replace#g

example:

    echo aabc | gsed 's/a/A/'
    echo aabc | gsed 's/a/A/g'

    # 好像只有s才支持`#` 边界符 
    echo aabc | gsed 's#a#A#'
    echo aabc | gsed 's#a#A#g'

# action, 操作码

    s 替换
    c change line
        $ gsed -i '/^import skele/c ahui' b.txt
        $ gsed -i '/^import skele/c\ahui' b.txt
    d 删除line
    i 插入line
    a 追加line
    q 退出 

pattern:

	[a-z]
	\[a-z\]
	^strin$
	\r \n

## p

	sed -n '1p' a.txt //不输出原文

	$ sed -n '2p' a.txt
	$ sed '2,3p' a.txt
	$ sed '/my/p' a.txt

## q
找到pattern 就退出：

	tail -f a.log | sed '/^failed$/q'

## s字符串替换

	$ sed -i "s/pattern/replace/" a.txt //第一行，只匹配一次
	$ sed -i "s#pattern#replace#g" a.txt //第一行，只匹配一次
	$ sed -i "s/pattern/replace/g" a.txt
	$ sed -i "s#pattern#replace#g" a.txt
	$ sed -i "n,ms/pattern/replace/g" a.txt //指定行
	$ sed -i "s/pattern/replace/ng" a.txt //指定该行的第n个字符开始搜索

	sed -z 's/\n/ /g'; # separate lines by NUL characters, default separator is '\n'

example:

	# delete first 5 characters
	sed -i 's/\(.\{5\}\)//' file
	# -r 与-i 不能合并！sed 不能合并参数的！
	sed -i -r 's/.{5}//' file

指替换所有文件：

    find ./ -type f -exec sed -i -e 's/apple/orange/g' {} \;

### 引用

	//&引用search
	$ sed 's/my/ha-&/g' my.txt 与 sed 's/my/ha-my/g' my.txt 相同
	//\1 引用search中的第一个括号
	$ sed 's/\(my\)/\1/g' my.txt 与 sed 's/my/my/g' my.txt 相同

## i and a
插入和追加

	$ sed '1 i a' pets.txt; # sed '1ia' pets.txt
	$ sed '1 a sth.' pets.txt

## search insert(s+a)
利用匹配追加与插入

	$ sed  '/my/a sth.' a.txt
	$ sed  '/my/i sth.' a.txt

## c替换整行

	$ sed '2c Sth. else' a.txt
	$ sed '/my/c Sth. else' a.txt # ignore the space after c

## d删除

	$ sed '2d' a.txt
	$ sed '/my/d' a.txt
	$ sed '2s/^pattern.*//' a.txt; # 清空第二行，而不是删除第二行
	$ sed '2{/pattern/d}' a.txt; # 删除第二行

# 行范围

## 合并行

	$ sed 'N;s/my/your/' pets.txt //当前行与下一行视为同一行
	$ sed 'N;s/\n/,/' pets.txt //合并奇偶行

## 指定行范围

	$ sed 'n,mp' n到m行
	$ sed '/from pattern/,/to pattern/d'
	$ sed '/from pattern/,+3d' //使用相对位置
	$ sed '1!p' //对行范围取反1!
	$ sed '2,$!p' //对行范围取反2,$!

# Multi Command, 命令打包

## 子命令
`{cmd}`

	# 对3行到第6行，匹配/This/成功后，再匹配/fish/，成功后执行d命令
	$ sed '3,6 {/This/{/fish/d}}' pets.txt

## 串行命令`;`

	# 从第一行到最后一行，如果匹配到This，则删除之；如果前面有空格，则去除空格
	$ sed '1,${/This/d;s/^ *//g}' pets.txt #用分号分割多个命令
	$ sed '2,$!{=;p}' //对行范围取反

当pattern 中没有字符时，串行命令就中断

	$ sed '$!d;=' ;只会打印最后一行行号

### 用分号分割命令;

	$ sed -n -e '=;p' myfile.txt #'=' 命令告诉 sed 打印行号，'p' 命令明确告诉 sed 打印该行（因为处于 '-n' 模式, 默认不会打印）
	$ sed -n -e '/search/=;p' myfile.txt

### 用-e分割

	$ sed -n -e '=' -e 'p' myfile.txt

	$ echo '1' | sed 's/1/a/;s/a/b/'
		b

# Hold Space
Hold Space 有四条命令:

1. g： 将hold space中的内容拷贝到pattern space中，原来pattern space里的内容清除
1. G： 将hold space中的内容append到pattern space\n后
1. h： 将pattern space中的内容拷贝到hold space中，原来的hold space里的内容被清除
1. H： 将pattern space中的内容append到hold space\n后
1. x： 交换pattern space和hold space的内容

	g  # pattern=hold
	G  # pattern+=nl+hold
	h  # hold=pattern
	H  # hold+=nl+pattern
	x  # swap hold and pattern
	d  # pattern_delete_top/cycle

示例1:

	$ cat t.txt
	one
	two
	three
	$ sed 'H;g' t.txt

	one

	one
	two

	one
	two
	three

![](/img/sed-hold-space.1.png)

> 每次匹配后，会默认输出pattern, 可以通过`sed -n` 禁止pattern 的输出. 或者通过`d` 删除pattern, 通过`p` 手动输出pattern

示例2：倒序文本

	$ sed '1!G;h;$!d' t.txt

其中：
1. 1!G —— 只有第一行不执行G命令，将hold space中的内容append回到pattern space
1. h —— 第一行都执行h命令，将pattern space中的内容拷贝到hold space中
1. $!d —— 除了最后一行不执行d命令，其它行都执行d命令，删除当前行

![](/img/sed-hold-space.2.png)

## replace newline with space
http://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed

	sed ':a;N;$!ba;s/\n/ /g' input_filename
	tr '\n' ' ' < input_filename
	sed -n 'H;$ {x;s/\n/ /g;p;}' file; # extra character ' '

	sed -z 's/\n/ /g'; # separate lines by NUL characters, default separator is '\n'

Explanation.

1. create a label via `:a`
1. append the current and next line to the pattern space via `N`
1. if we are before the last line, branch(goto) to the created label `$!ba` (`$!` means not to do it on the last line (as there should be one final newline)).
1. finally the substitution replaces every newline with a space on the pattern space (which is the whole file).

> `:a` is just a label. `ba` will goto the label `:a`, `t loop` will go to lable `loop`

	:  # label
	=  # line_number
	a  # append_text_to_stdout_after_flush
	b  # branch_unconditional
	c  # range_change
	D  # pattern_ltrunc(line+nl)_top/cycle
	i  # insert_text_to_stdout_now
	l  # pattern_list
	n  # pattern_flush=nextline_continue
	N  # pattern+=nl+nextline
	p  # pattern_print
	P  # pattern_first_line_print
	q  # flush_quit
	r  # append_file_to_stdout_after_flush
	s  # substitute
	t  # branch_on_substitute
	w  # append_pattern_to_file_now
	x  # swap_pattern_and_hold
	y  # transform_chars

# regex
关于regex, 见[Posix Regex](/p/regex.html)
sed 默认使用BRE 正则， 使用 -r 参数是 sed 会支持ERE 正则

	echo 'a1-2-3-' | gsed -n -r '/([[:digit:]]-){3,4}/p'

特殊字符: `$` 在搜索时是需要转义的, `&` 替换时是需要转义的

	//&引用search
	$ sed 's/my/ha-&/g' my.txt 与 sed 's/my/ha-my/g' my.txt 相同
	//\1 引用search中的第一个括号
	$ sed 's/\(my\)/\1/g' my.txt 与 sed 's/my/my/g' my.txt 相同

> 最新的sed 好像在-r 参数时，会支持perl 正则了

# Reference
- [sed 简明教程]

[sed 简明教程]: http://coolshell.cn/articles/9104.html
