---
layout: page
title:	
category: blog
description: 
---
# Preface

# show charactors
See tab, new line:

	:set list
	:set listchars=tab:>-,eol:<,nbsp:%
	:set lcs=tab:\|\ ,trail:-

carriage return:

	:set ff=unix
	:set fileformat+=mac
	"显示回车(Carriage Return)
	:e ++ff=unix

## expand tabl

    :set expandtab

# style

	:set tw=80
	:setlocal cuc cursorcolumn "光标对齐
	:setlocal cul cursorline
	:hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
	:hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white

## wrap

	:set nowrap

## Screen Redraw
Refresh Screen Render

	<C-L>
	:redraw!
	:redrawstatus!

## style indent 

	set ai " autoindent 
	set si " smartindent " set smartcase
	
	" Format motion with internal function or external given with `equalprg`
	={motion}
	" 作用visual 选择format 的范围
	{Visual}=

Refer to `:h =`

## style format text 格式化文本

用gq命令手动格式化

	gq{motion}
	gqap #gq是格式化，ap　是a paragraphp
	gqgp "格式化当前行

	gw{motion}		Format the lines that {motion} moves over.  Similar to
			|gq| but puts the cursor back at the same position 

gq受formatoptions的影响,详见`:h fo-table`(formatoptions), eg: `:set fo=tcoq`.

	t	Auto-wrap text using textwidth
	c	Auto-wrap comments using textwidth, inserting the current comment
		leader automatically.
	r	Automatically insert the current comment leader after hitting
		<Enter> in Insert mode.
	o	Automatically insert the current comment leader after hitting 'o' or
		'O' in Normal mode.
	q	Allow formatting of comments with "gq".
		Note that formatting will not change blank lines or lines containing
		only the comment leader.  A new paragraph starts after such a line,
		or when the comment leader changes.
	w	Trailing white space indicates a paragraph continues in the next line.
		A line that ends in a non-white character ends a paragraph.
	
	t：根据 textwidth 自动折行；
	c：在（程序源代码中的）注释中自动折行，插入合适的注释起始字符；
	r：插入模式下在注释中键入回车时，插入合适的注释起始字符；
	q：允许使用“gq”命令对注释进行格式化；
	n：识别编号列表，编号行的下一行的缩进由数字后的空白决定（与“2”冲突，需要“autoindent”）；
	2：使用一段的第二行的缩进来格式化文本；
	l：在当前行长度超过 textwidth 时，不自动重新格式化；
	m：在多字节字符处可以折行，对中文特别有效（否则只在空白字符处折行）；
	M：在拼接两行时（重新格式化，或者是手工使用“J”命令），如果前一行的结尾或后一行的开头是多字节字符，则不插入空格，非常适合中文

## style align
center, left, right

	Center align: “:ce {width}”
	Right align: “:ri {width}”
	Left align: “:le {indent}”

	Format paragraph: “gqip”
	Format current selection: “gq”
	“:help formatting” “:help text-objects”

## style case

	gU{motion} 转大写
	gu{motion} 转小写
	g~{motion} 大小写切换
	#要使一个操作以行为单位，可以双写操作两次，比如是cc,dd
	gugu 简写guu
	gUgU 简写gUU
	g~g~ 简写g~~

> 在visual 下，`u/U` 转换大小写

## command

	set showcmd 显示输入命令

## clear screen
[Prevent Applications Like Vim and Less Clearing Screen on Exit](http://chenyufei.info/blog/2011-12-15/prevent-vim-less-clear-screen-on-exit/)

Preference - profiles - Terminal - select 'vt100' as terminal emulation.

On linux:

	export TERM=vt100

