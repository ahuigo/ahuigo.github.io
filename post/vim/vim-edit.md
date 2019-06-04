---
title: Vim Edit
date: 2019-05-29
---
# 复制/删除/粘贴(copy/del/paste)

## del 删除

	d2w
	d^ d$
	dd 删除整行

	x 代表dl(删除当前光标下的字符)
	X 代表dh(删除当前光标左边的字符)
	D 代表d$(删除到行尾的内容)
	C 代表c$(修改到行尾的内容)
	s 代表cl(修改一个字符)
	S 代表cc(修改一整行)

可以通过map 实现

	<C-h> 删除左边一个字符
	<C-w> 删除左边一个单词
	<C-u> 删除左边所有单词(单行)

还有更强大的:d

	:[range]d [x] "x是一个register
	:2d q "删除第二行，并保存到寄存器。

### dt,df,ct,cf

    To delete forward up to character 'X' type dtX
    To delete forward through character 'X' type dfX
    To delete backward up to character 'X' type dTX
    To delete backward through character 'X' type dFX

## copy & paste

### Copy
1. 删除(del)本身带复制
1. 通过y复制

在v模式也可使用y复制

	yw
	"ayw 指定寄存器
	Y=yy
	"Ayw ”大写的寄存器实现追加数据

    :%y+ " Copy all text

查看寄存器

	:reg

### paste

	p 在光标后粘贴
	P 大写在光标前粘贴
	"+p 调用系统剪切板粘贴

### registers 复制寄存器
- vim默认的寄存器不包含系统剪贴板，而gvim则开启了这一剪贴板
- 宏macro，复制yank，粘贴paste, 都是使用的寄存器

你可以通过vim --version|grep clipboard查看是否开启了剪贴板

	:registers  :reg 查看寄存器
	"+ 系统剪贴板
	"* 鼠标中键剪贴板

    匿名寄存器 ""
    编号寄存器 "0 到 "9
    小删除寄存器 "-
    26个命名寄存器 "a 到 "z
    3个只读寄存器 ":, "., "%
    Buffer交替文件寄存器 "#
    表达式寄存器 "=
    选区和拖放寄存器 "*, "+, "~
    黑洞寄存器 "_
    搜索模式寄存器 "/

> mac/windows 中, `"*` 与 `"+` 指的都是同一个系统剪贴板

## c_CTRL-R i_CTRL-R(paste)
在:cmd模式或者插入模式下,<c-r>非常有用——快速粘贴出寄存器字符串。

In either insert mode or command mode (i.e. on the : line when typing commands), continue with a numbered or named register:

	a - z the named registers
	" the unnamed register, containing the text of the last delete or yank
		<c-r>"
	% the current file name
	# the alternate file name
	* the clipboard contents (X11: primary selection)
	+ the clipboard contents
	/ the last search pattern
	: the last command-line
	. the last inserted text
	- the last small (less than a line) delete
	ctrl+w the word that cursor locate.

`<c-r>`也可用于计算。

	=5*5 insert 25 into text (mini-calculator)

> See :help i_CTRL-R and :help c_CTRL-R for more details, and snoop around nearby for more CTRL-R goodness.

# Extra
Increment/decrement digit:

    <C-a>
    <C-x>

# insert 插入

## :read

	:[range]r[ead] !{cmd}
	:[range]r[ead] [name] "name:default current file

## `{motion}!cmd`
使用外部cmd处理`motion`
