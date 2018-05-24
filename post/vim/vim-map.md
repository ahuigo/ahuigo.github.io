---
layout: page
title:	vim 之 map命令
category: blog
description:
---
# Preface
map命令手册位于：

	:h map.txt

map 命令语法：

   map {lhs} {rhs}

# map command list - map 命令列表

	{cmd} [{attr}] {lhs} {rhs}

	where
	{cmd}  is one of ':map', ':map!', ':nmap', ':vmap', ':imap',
		   ':cmap', ':smap', ':xmap', ':omap', ':lmap', etc.
	{attr} is optional and one or more of the following:
		<buffer>, <silent>, <expr> <script>, <unique> and <special>.
		   More than one attribute can be specified to a map.
	{lhs}  left hand side, is a sequence of one or more keys that are being
		   mapped.
	{rhs}  right hand side, is the sequence of keys that the {lhs} keys are
		   mapped to.

map 命令按使用模式切分为：

	n	Normal
	v	Visual and Select
	s	Select
	x	Visual
	o	Operator-pending
	!	Insert and Command-line
	i	Insert
	l	":lmap" mappings for Insert, Command-line and Lang-Arg
	c	Command-line

> tips: 还有一种Ex-mode.这种模式支持多次键入cmd. 它不支持map 和abbrev. 参阅`:h Q` `:h gQ`

Just before the `{rhs}` a special character can appear:

	*	indicates that it is not remappable
	&	indicates that only script-local mappings are remappable
	@	indicates a buffer-local mapping

解绑定前缀为un：

	:unmap
	:iunmap
	:cunmap

非嵌套前缀nore (non-remappable):

	:noremap
	:inoremap
	:cnoremap

# attr
map attr list: `<script> <buffer> <buffer>, <silent>, <expr> , <unique> and <special>` 等

## script map
`<script>` 关键字可以被用来使一个映射仅对当前脚本有效。参见 `|:map-<script>|`。

## buffer map
`<buffer>` 关键字可以被用来使一个映射仅对当前缓冲区有效。参见 `|:map-<buffer>|`。

	//The "<buffer>" argument can also be used to clear mappings: >
	:unmap <buffer> ,w
	:mapclear <buffer>

## unique map
<unique> 关键字可以被用来当一个映射已经存在时不允许重新定义。否则的话新的映射 会简单的覆盖旧的。参见 `|:map-<unique>|`。

	:nnoremap <leader>x dd
    :map <buffer> <unique> <leader>x  /[#&!]<CR> | " failed as map exists

如果要使一个键无效,将之映射至 <Nop> (五个字符)。下面的映射会使 <F7> 什么也干 不了:

	:map <F7> <Nop>| map! <F7> <Nop>

注意 <Nop> 之后一定不能有空格。

## silent map
To define a mapping which will not be echoed on the command line:

	:map <silent> ,h /Header<cr>

Messages from excuted command are still given through. To shut then up, add `:silent {cmd}`

# 显示当前映射

	:map
	:imap
	:cmap

## 显示特定的map

	:map \y
	:imap <D-V>

# object map(Movement Mapping, Operator-Pending Mappings)
> http://learnvimscriptthehardway.stevelosh.com/chapters/15.html

press `dp` to delete(d) all the text inside the parentheses(p)
press `cp` to change(c) all the text inside the parentheses(p)

	:onoremap p i(

Vim will operate text from current cursor position to new position, if there is no visual block selected.

	:onoremap b /return<cr>

## change start
Use visual block as object via `:normal`

	:onoremap in( :normal! f(vi(<cr>

# special key
特殊字符 `:h keycodes`

	<C-I>==<TAB>
	<C-M>==carriage-return
	<C-H>==Backspace
	:h keycodes 或者 :h key-notation

应该对这些键引起重视，比如以下两个映射是完全等价的.

	map <TAB> >
	map <C-I> >

## 关于mac的特殊键

mac 会拦截 Alt+字符, 并替换成特殊字符. 比如:<A-p>会被mac 默认的keyboard layout 替换成 π(# map 中我会总结更多的细节)

	# 默认的mac keyboard layout下， 该映射无法捕获到<A-p>
	:map <A-p> <ESC>
	# 在mac下应该用π 代替<A-p>
	:map π <ESC>

另外, mac下的左右shift键盘信号是一致的, 你永远都不能判断左右shift(反正我也不用)

## leader

	//default mapleader
	let mapleader = '\'
	echo mapleader
	map <leader>p "*p		"'

local leader, only take effect for certain types of files, like Python files or HTML files.

	:let maplocalleader = "\\"

Now you can use `<localleader>` in mappings and it will work just like <leader> does (except for resolving to a different key, of course).

# 注释
在一个映射后不能直接加注释,因为 " 字符也被当作是映射的一部分。你可以用 |" 绕 过这一限制。这实际上是开始一个新的空命令。例如:

	:map <Space> W| " Use spacebar to move forward a word"
	:noremap <F10> :let current_dir=expand("%:h")\|exec 'NERDTree' current_dir <CR>

# map key issue - map 按键相关

## <A-char> in mac
Alt+Char 在mac下会输出特殊字符（默认的mac keyboard layout）. 如果想绑定Alt+Char. 有三种方法:
- 修改mac 的keyboard layout, 参阅[disable typing special characters when pressing option key in mac ](http://stackoverflow.com/questions/11876485/how-to-disable-typing-special-characters-when-pressing-option-key-in-mac-os-x
)
- 在iTerm2/terminal 中配置：set `Alt` as `Meta`
- 直接映射特殊字符

	:map å 2w

## Ctrl+Char 问题
vim 对Ctrl+Char的支持其实非常有限: <C-char>对应的keycode就是 char & 0x1F, 它只能表示31个keycode.(这个char有一个范围,不能是数字, 只能是C0 Control_character) <C-a> 与 <C-A> 对vim而言都视为是0x01 (因为 0x41 & 0x1f == 0x61 & 0x1f).

参阅:

- [<C-char> map in vim](http://superuser.com/questions/580110/why-does-vim-require-every-key-mapping-to-have-a-unique-ascii-code).
- [Control Character](http://zh.wikipedia.org/wiki/%E6%8E%A7%E5%88%B6%E5%AD%97%E7%AC%A6)

## Ctrl+s/Ctrl+q 问题
mac 终端默认会拦截Ctrl+s/Ctrl+q, 它们属于终于的控制符。你可以从这里获得更多： `stty -a` and  `man stty`.

1. <c-s> will sent stty stop signal which would stop terminal character output.
1. <c-q> will sent stty start signal which would resume terminal character output.

此时，如果终端需要绑定这两个按键，可以关闭它们(在~/.profile_private 或者 .zshrc 或者 .bashrc 中):

	stty start undef
	stty stop undef

## fastcode
如果需要map `Ctrl+1` , 只能将它映射到别的空闲keycode(比如我在iTerm2中的keymap中设定Ctrl+1 输出字符序列`C-1` ).
然后在map命令中直接指定vim keycode为`{lhs}`

    :inoremap C-1  some str

	或者这样
    :set <F13> C-1
    :imap <F13> what ever u want

	或者直接指定16进制
    :imap <char-0x20> space

> 这种作为`{lhs}`的字符序列在vim 中叫fastcode map ,参阅：[fastcode map](http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim)
> 如果需要记录所有vim按键：可以使用vim -W myTypedKey.txt  [find out what keys I just typed in vim](http://superuser.com/questions/278170/in-vim-can-i-find-out-what-keys-i-just-typed)

Entering literal characters & terminal codes Edit:

1. To enter a literal character in Vim, first type `Ctrl-v`, followed by a single keystroke. Hence, typing `Ctrl-v` then `Esc` will produce `^[`
2. To enter a terminal keycode in Vim, first type `Ctrl-v`, followed by the keystroke we want to obtain the term keycode from. Hence, typing `Ctrl-v + Shift-Down_arrow` will produce `^[[1;2B`.

更多参考：
- [vim mapping keys](http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_2)) 所描述的那样, 直接从keycode 做map
- Type `:set termcap` to see which keycodes are unused.

# command
Vim 编辑器允许你定义你自己的命令。你可以像运行其他命令行命令一样运行你自定义的 命令。 要定义一个命令,象下面一样执行 ":command" 命令:

	:command DeleteFirst 1delete
	:command! DeleteFirst 1delete | "重新定义

现在当你执行 ":DeleteFirst" 命令时,Vim 执行 ":1delete" 来删除第一行。 > Note the capital "D" - user-defined commands must begin with a capital letter. See :help command

## 列出用户命令：`command`

	:command | :com


## 参数

### 参数个数
无参数(0) 一个参数(1) 任意数目的参数(*) 没有或一个参数(?) 一个或更多参数(+)

	-nargs=0
	-nargs=1
	-nargs=*
	-nargs=?
	-nargs=+

### 参数形式

使用参数 在命令的定义中,<args> 关键字可以用来表示命令带的参数。例如:

	:command -nargs=+ Say :echo "<args>"

现在当你输入

	:Say Hello World

Vim 会显示 "Hello World"。然而如果你加上一个双引号,就不行了。例如: `:Say he said "hello"`
要把特殊字符放到字符串里,必须在它们的前面加上反斜杠,用 "<q-args>" 就可以:

	:command -nargs=+ Say :echo <q-args>

现在上面的 ":Say" 命令会引发下面的命令被执行: `:echo "he said \"hello\""`
关键字 <f-args> 包括与 <args> 一样的信息,不过它将其转换成适用于函数调用的格 式。例如:

	:command -nargs=* DoIt :call AFunction(<f-args>) :DoIt a b c

会执行下面的命令:

	:call AFunction("a", "b", "c")

## 行范围

	-range 允许范围;缺省为当前行。
	-range=% 允许范围;缺省为整个文件。
	-range={count} 允许范围;只用该范围最后的行号作为单个数字的参数,其缺 省值为 {count}。

当一个范围被指定时,关键字 <line1> 和 <line2> 可以用来取得范围的首行和末行的行 号。例如,下面的命令定义一个将指定的范围写入文件 "save_file" 的命令 -

	:command -range=% SaveIt :<line1>,<line2>write! save_file

## 其它example

	rgrep. 'command!' ~/.vim

	command! -nargs=*
	\	EMCommandLineMap
	\   call EasyMotion#command_line#cmap([<f-args>])
	command! -nargs=1
	\	EMCommandLineUnMap
	\   call EasyMotion#command_line#cunmap(<f-args>)


# map operator
> :h omap-info
> :h g@ - call the function set by operatorfunc(following motion), e.g.: g@iw

    " 一次性set
	nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@
	vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

	function! GrepOperator(type)
		echom a:type
	endfunction

Note:

- Pressing `viw<leader>g` echoes `v` because we were in characterwise visual mode.
- Pressing `Vjj<leader>g` echoes `V` because we were in linewise visual mode.
- Pressing `<leader>giw` echoes `char` because we used a characterwise motion with the operator.
- Pressing `<leader>gG` echoes `line` because we used a linewise motion with the operator.
