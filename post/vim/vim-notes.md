---
title: vim 笔记
priority:
---
# vim 笔记
本文是vim 相关的总结，不会有太多的注释 —— 只是方便回顾.

> 使用vim 时建议将key repeat调到最快, 把key delay调到最小
> 很多时候我会用Ctrl+c 代替 ESC(但是两者不是等价的)

# help 帮助
> Refer to : http://vim.wikia.com/wiki/Learn_to_use_help

[vim-help](/p/vim/vim-help)

## visual模式

### base visual

	#v模式下，可按o（other end）到另一头
	v
	V 行选
	ctrl+v 矩形块选 #对于矩形选而言，o是垂直切向，O是水平切向

	gv #回到上次的选择

### range

	V<line_number>G
	V<line_number>j
	v/<pattern>/e
	vas
	vap
	V2aB

### 高级用法

	ctrl+v 块选后，对单行的操作会反映到所有行，比如IA行操作
	#选中了文本后，可以改变大小写
	~ 大小写转换
	U  转大写
	u 转小写
	#选中了文本后，以一个字符填充
	rx #这样就把所有字符变成了x了

### 位置
处于visual时，还可以控制选择范围的方向

	o 到另一端
	O 左右切换

# 复制/删除/粘贴(copy/del/paste)

## del 删除（del）

	d2w
	d^ d$
	dd 删除整行

	x 代表dl(删除当前光标下的字符)
	X 代表dh(删除当前光标左边的字符)
	D 代表d$(删除到行尾的内容)
	C 代表c$(修改到行尾的内容)
	s 代表cl(修改一个字符)
	S 代表cc(修改一整行)

	<C-h> 删除左边一个字符
	<C-w> 删除左边一个单词
	<C-u> 删除左边所有单词(单行)

还有更强大的:d

	:[range]d [x] "x是一个register
	:2d q "删除第二行，并保存到寄存器。

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
	P 在光标前粘贴
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


# insert 插入

## :read

	:[range]r[ead] !{cmd}
	:[range]r[ead] [name] "name:default current file

## `{motion}!cmd`
使用外部cmd处理`motion`

# mode

	*gQ*
		Ex-mode
		:h Ex-mode
	:
		command mode
	<ESC>
		normal mode

## cmdline-window
See :h cmdline-window for more details

	q: or c_CTRL-F -> cmdline window for commands and you will edit your command in normal mode.
	q/ -> cmdline window for search forward
	q? -> cmdline window for search backward

	Ctrl-C will take you out of cmdline-window
	<CR> will take you out of cmdline-window and excute command.

##　命令(command mode)

### 命令历史记录

按: or /都会进入命令行,这两种状态都有一个命令历史记录(相互独立的)
其中冒号命令的历史记录，可以通过:history查看

	:history
	:history / 查看搜索的历史记录
	:set history=50 "A history of ":" command

在命令行按上下键,就可以在命令行历史记录间做切换,比如输入/the并按上下键

### 新开一个shell

	:shell ＃这个shell是vim的子shell

# search 搜索
[vim-pattern](/p/vim-pattern)

# change 替换

## 基础的替换命令

	cw 替换一个单词
	C=c$
	cc 改变整行

	s=cl
	S=cc

	r 仅替换一个字符
	R

	~ 切换字符的大小写，并把光标移动到下一字符

## substitute s替换
>更多替换请参照:help sub-replace-special

基本格式如下：

	:[range]s/pattern/replace/[flags]
	:[range]s+pattern+replace+[flags]
	:[range]s?pattern?replace?[flags]

	:%s/\([^-]*\)-\(.*\)/\2 \1/gc   "vim中的替换也可以用到正则反引用\2\1

> 一般情况下\r\n分别代表回车与换行，但是在`:%s/pattern/replace` 中的replace，replace 只能用'\r'表示换行，'\n'表示回车
> 更多见[vim-pattern](/p/vim-pattern)

Example: 删除注释，先用V 选中，然后

    :s#^//##g 删除注释//

## 外部程序替换

	!{motion}{program} "program处理完了后，替换 motion
	:[range]!{program} "program处理完了后，替换 range

eg:

	!{motion}{program}
	{motion}作为program的输入，其输出会替换{motion}处的内容

	#比如我想让一到５行的内容经过sort,这个命令会从normal进入到命令行
	!5Gsort<enter>
	:.,5!sort<enter>

	!!{program} #此时motion为!代表当前行
	#统计当前行
	!!wc
	:.!wc

# Delete 删除

	:g/^\s*$/d

	:g!/^\s*$/d
	:v/^\s*$/d

# 写入(w)

	"写入命令
	:[range]w !{cmd}
	:w !wc
	"写入文件
	:[range]w {file}
	:h :w "寻求帮助


# 信息(message)

## 文本信息

	ga " 查看光标下字符内码(eg.UNICODE)
	g8 " 查看光标下字符utf-8

## 光标信息

	ctrl+g "行数 文件名 :h CTRL-G OR :h :f
	g ctrl+g "光标位置：行数，列数，单词数，字节数..  "For more info ,:h g_CTRL-G

## g(g)
g命令归类在message可能不适合，没办法g本来就是一个大杂烩．

	:h g
	gI 在行首插入(空白符也属于行)
	g~{motion} "motion区大小写切换
	gu{motion}
	gU{motion}

	gv "重新选择上次选中的visual block

# 恢复(recover)

## swp

	set backup "设置备份

### 基本恢复
	vim -r a.txt #读取交换文件a.swp

### 交换文件在哪里？
	vim -r

### 指定交换文件
	vim -r a.txt.swp

## viminfo
> viminfo信息中保存了命令行历史(history)、搜索字符串历史(search)、输入行历史、非空的寄存器内容(register)、文件的位置标记(mark)、最近搜索/替换的模式、缓冲区列表、全局变量等信息

保存与读入file(the default file is `~/.viminfo` )

	:wviminfo [file] "in current directory
	:rviminfo [file]

viminfo记录着以下信息：

	命令行 & 搜索命令的历史记录
	寄存器内容
	文件标记
	缓冲区列表
	全局变量

viminfo还可以保存更多的记录，你需要配置`set viminfo`, 比如 `:set viminfo='100,f1,<50,s10"`

	'100 "保存最后100个文件的标记
	f1 "存储文件标记(marks)．f0则不存储标记
	<50 "每个寄存器最多保存50行

Example: `:set viminfo='50,<1000,s100,:0,n~/vim/viminfo`

	'50		Marks will be remembered for the last 50 files you
			edited.
	<1000		Contents of registers (up to 1000 lines each) will be
			remembered.
	s100		Registers with more than 100 Kbyte text are skipped.
	:0		Command-line history will not be saved.
	n~/vim/viminfo	The name of the file to use is "~/vim/viminfo".
	no /		Since '/' is not specified, the default will be used,
			that is, save all of the search history, and also the
			previous search and substitute patterns.
	no %		The buffer list will not be saved nor read back.
	no h		'hlsearch' highlighting will be restored.

Refer to : `:h viminfo` and `:h :set`

## Session 会话
> http://easwy.com/blog/archives/advanced-vim-skills-session-file-and-viminfo/

如果因为别的事儿要处理 导致需要关闭vim，可以先保存当前vim会话

>会话包括:缓冲区/当前目录/窗口布局和大小/tabs/mapping/折叠/当前路径
会话不包括：寄存器这些状态

	:mksession project.vim #default Session.vim in current directory
	:source project.vim #恢复会话
	vim -S project.vim #直接打开会话

### 会话切换
如果你有很多项目会话, 可这样切换：

	:wall ＃先保存所有文件
	:mksession! project1.vim #保存项目１的会话
	:source project2.vim #打开项目2的会话

> 如果会话文件`Session.vim` 所在的目录还存在一个 以会话名加`x.vim` 为文件名的文件, 比如`Sessionx.vim`，那么在`source Session.vim` 会继续`source Sessionx.vim`

    "In Sessionx.vim
    set path+=/usr/local/include

## view 视图
>会话保存了所有vim窗口的属性，但是如果你只想保存当前窗口的属性，可以用视图

	:mkview 1 #保存视图到1，1是任意指定的视图文件，可以不加
	:loadview #恢复
	:loadview 1 #从1中恢复


# macro 宏

	q{register}命令是启动宏录制的
	@{register}是使用宏的
	要说明的是这个register：
	1．　这个register与yank(复制)是共用的，能相互影响
	2．　大写的register，会往register中追加数据，如qC、"Cy会旆c寄存器中追加数据．

## 重复
很多工作都可以用数字来重复，比如你在normal状太中输入以下键会发生什么？

	10oThis sentence will be repeated for 10 times!<ESC>

还比如.操作，还比如<C+V>,还比如更强大的宏。

# Statistic & Math

## 统计字数

	g ctrl+g #如果你想统计部分字数，可以使用visual模式选中后再执行此命令
	:% !wc

## Calculate
in insert mode:

    "<C-r>用于计算也非常方便。
	=1-5*5 "insert -24 into text (mini-calculator)

in normal mode:

    <C-A> 数字会自增
    <C-x> decrement


# Text Complete
YouCompleteMe(YCM), 使用了clang 编辑器做后端，可在编写程序时分析代码提供准备的自动补全

# File Jump

## Jump via path

    set path+=/usr/local/include
    "find recursive
    set path+=/usr/local/**

Then if you at word `evhttp.h`, press:

    "jump to evhttp.h in current window
    `gf`
    :find evhttp.h
	404.md

    "jump to evhttp.h in new window
    `Ctrl-w_ctrl-f`

## taglist
函数列表可以通过vim 自带的taglist 实现

有一个插件Tagbar可以实现这个功能。可以绑定F8

  nmap <F8> :TagbarToggle<CR>

## tag
Refer to : http://easwy.com/blog/archives/advanced-vim-skills-use-ctags-tag-file/

Tag 是纯文本文件, 它保存了:

1. tagname: 函数、类、结构、宏等标识tagname
2. tagfile: 标识所处的文件和位置tagfile
3. tagaddress: 可通过Ex 命令跳转到这些标识
4. term: 兼容vi, 值为`;"`
4. field: 可选,tagname 的类型，比如函数、变量、宏...

tag 格式

    {tagname} {TAB} {tagfile} {TAB} {tagaddress}{term} {TAB} {field} ..

tag 文件中的元信息多以`!_TAG_` 打头，`_TAG_FILE_SORTED` 为0 表示未排序，1排序，2忽略大小写排序

    !_TAG_FILE_SORTED<Tab>1<Tab>{anything}

### Create tag
谁生成tag 文件？
可以通过`ctags`, `Exuberant Ctag` 等程序，ctags支持33种语言；emacs 使用etags 生成tag

    "遍历src 目录并生成tags
    shell> ctags –R src
    shell> ctags src

ctags 对lua 支持不友好，需要定义生成规则: http://blog.csdn.net/zdl1016/article/details/9118579

php:

	ctags -h \".php\" -R \
		--exclude=\"\.svn\" \
		--totals=yes \
		--tag-relative=yes \
		--PHP-kinds=+cf \
		--regex-PHP='/abstract class ([^ ]*)/\1/c/' \
		--regex-PHP='/interface ([^ ]*)/\1/c/' \
		--regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'

### Config tag

	"specify tags path
	:set tags=./tags,tags

### Jump via tag

    :tag <tagname>
    "ts[elect] tag match list
    :ts <tagname>

tag 支持vim 正则, 但是需要在前加上'/'

    :ts /\<getUser\>

tag stack:

	ctrl-t 跳到之前的tag(tag stack)
	ctrl-] 跳到tag定义处

    "The list of jump tag stack
    :tags

For detailed tag and search : `:help tagsrch`

## cscope & GNU global
tag 只能根据tag 做跳转，无法查看源码的结构。

c scope 用于查看c 源码的结构：函数在哪里调用
cscope 生成的符号文件做跳转，好像更新符号文件时比较慢。可以搭配GNU global，global 更新符号文件时非常快

### cscope
cscope 可以生成符号索引(cscope database), 默认是交互窗口(通过Ctrl-D 退出，Ctrl-n/p, TAB移动)

#### cscope Config

	:set csprg=/usr/bin/cscope
	"weather to open quickfix window
	:set cscopecscopequickfix=s+,d+
	"0 find cscope database first; 1 find tags first
	:set cscopecscopetagorder=1

Refer to `:h cscope-suggestions`

#### create cscope database

    cscope -Rbkq
    -R
        Recurse
    -b
        Build the cross-reference only. You would enter into an interactively window without `-b`
    -k
        `kernel mode`, turn off the default use of directory /usr/include, because kernel generally do not use it.
    -q
        Enable fast symbols lookup via an inverted index. This option cause cscope to create 2 more files(cscope.in.out, cscope.po.out) in addition to the normal database(cscope.out). A large project should enable this option.
    -i<file>
        cscope will scan the source files listed in <file>. The stdin `-` is also accepted
        deafult: cscope.files
    -C
        Ignore case
    -P<path>
        prepend <path> to relative file name so that you do not need to change directory.


By default, cscope only search `*.lex, yacc(.c,.h,.l,.y)`. You could provide a filelist that cscope using for searching by the following shell:

    find . -name "*.c" -o -name '*.cc' -o -name '*.h' > cscope.files
    cscope -bkq -i cscope.files
    //or
    find . -name "*.c" -o -name '*.cc' -o -name '*.h' | cscope -bkq -i-

Refer to: `:h cscope` and `man cscope`

#### use cscope database
add database

    :cscope add cscope.out
    "find c language symbol: function, macro, enum, etc.
    :cscope find s [c_symbol]

query cscope

    :cs find {querytype} {name}
    :cs find s main

    {querytype} corresponds to the actual cscope line interface numbers as well as default nvi commands:

        0 or s: find c symbols such as function, macro
        1 or g: find this definition(like ctags)
        2 or d: find functions called by this function
        3 or c: find functions calling this function
        4 or t: find this text
        6 or e: find this egrep pattern
        7 or f: find this file
        8 or i: find files#include this file

## Search File

	lookupfile
		可以从tag 中查找文件，也可以从文件列表filelist 查找文件
	ctrlP
		好像比lookupfile 慢点？

## quickfix
[vim-quickfix](/p/vim-quickfix)

## buffer 缓冲区列表(buffer list)
[vim-window](/p/vim-window)

# vimdiff 查看不同

	vimdiff a.txt b.txt
	:vertical diffsplit b.txt #在vim命令中执行diff
	:diffsplit c.txt

## 同步滚屏
如果想在比较时，两个窗口能同时滚动，则：

	:set scrollbind :set scb //默认

## 跳到不同处

	]c  下一个不同处
	[c	上一个不同处

	" easy diff goto
	noremap <unique> <C-k> [c
	noremap <unique> <C-j> ]c


## 消除差异

	:diffupate #随着文件改动，高亮并不实时更新，这个命令的作用就是实时更新
	:[range]diffget [bufspec] //替换当前文件块, bufspec指文件关键字 或者 文件编号(bufsepc通过:buffers查看)
	:[range]diffput [bufspec] //用当前文件块替换别的文件块
	:dp #选择当前文件块.相当于不带参数的diffput
	:do #选择别的文件块.相当于不带参数的diffget

get or put all:

	:%diffput [bufid]
	:%diffget [bufid]

# mouse 鼠标

	:set mouse= #设定哪些模式可以用Mouse
	:set mouse=a
	:set mousemodel #控制鼠标单击的效果
	:set mousetime #双击鼠标的间隔时间
	:set mousehide #键入时隐藏鼠标
	:set selectmode #控制如何进入select模式

如果 想在mouse mode 下copy text via `Cmd+c`:

	Press Alt while selecting with the mouse. This will make mouse selection behave as if mouse=a was not enabled.
	OS X (mac): hold alt/option while selecting (source)

# vim-ide
Refer to [vim-ide](/vim-ide)

# Reference
- [vim for php developers]
- [Alt-in-mac]
- [learn-vim]
- [vim for beginner]

## Book
[vim for php developers]: http://slidedeck.io/BlackIkeEagle/vim-for-php-developers
[Alt-in-mac]:http://superuser.com/questions/124336/mac-os-x-keyboard-shortcuts-for-terminal
[learn-vim]: http://learnvimscriptthehardway.stevelosh.com/ 36
[vim for beginner]:http://coolshell.cn/articles/11312.html
