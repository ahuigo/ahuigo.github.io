---
title: Vim Edit
date: 2019-05-29
---
# vim的编辑模式
vim 支持的模式很多：
1. normal 正常模式（大部分时间都是处于这个模式），这个模式下支持丰富的[光标移动命令如hjkl wbe](/p/vim/vim-motion)
2. edit mode: 这个模式下，才能做代码编辑。
    1. 进入edit mode的方法
        1. `i`光标前插入, `I`行首插入
        1. `a`光标后插入, `A`行尾插入
        1. `o`下一行插入, `O`下一行插入
    1. 退出edit mode的方法有几种:
        1. `ctrl+c` 强制退出到normal 正常模式
        1. `Esc` 普通退出到normal 正常模式
    1. 推荐配置edit mode版的readline 快捷键: ctrl+f/b, ctrl+a/e,  ctrl+u/k ....
3. visual mode: 这个其实是选择模式
    1. `v`: 常规选择
    1. `V`: 多行选择
    1. `Ctrl+v`: 多列选择
4. command mode: 指令mode

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
d系列与c系列两大删除命令,　与t、f两大字符转命令，结合后非常强大：

1. To delete forward up to character 'X' type: `dtX`
1. To delete forward through character 'X' type: `dfX`
1. To delete backward up to character 'X' type: `dTX`
1. To delete backward through character 'X' type: `dFX`

## copy & paste

### Copy
常见的有两种复制方法
1. 删除(del命令)本身就是删除的同时带复制
1. 通过y复制

在v模式也可使用y复制

1. `yw`  "复制当前词(复制到普通寄存器)
1. `"*yw` "复制当前词(复制到系统寄存器`*`, 这是系统粘贴板)
1. `"Ayw` "复制当前词(复制到系统寄存器A)
1. `Y`或 `yy` "复制一行
1. :%y+ " Copy whole text

查看复制到寄存器的内容

	:reg

### paste 粘贴

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
## math
Increment/decrement digit:

    <C-a>
    <C-x>

# replace
## dos unix format
    :e ++ff=dos
    :e ff=dos
    :e ++ff=mac
    :e ff=mac
    :e ++ff=unix
    :e ff=unix

dos2unix

    %s/\r//g

In the syntax `s/foo/bar`, `\r` and `\n` have different meanings, 

    For foo:
    \r == "carriage return" (CR / ^M)
    \n == matches "line feed" (LF) on Linux/Mac, and CRLF on Windows

    For bar:
    \r == produces LF on Linux/Mac, CRLF on Windows
    \n == "null byte" (NUL / ^@)


# insert 插入

## :read

	:[range]r[ead] !{cmd}
	:[range]r[ead] [name] "name:default current file

## `{motion}!cmd`
使用外部cmd处理`motion`
