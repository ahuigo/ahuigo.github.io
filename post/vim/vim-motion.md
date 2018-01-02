---
layout: page
title:	vim-motion
category: blog
description:
---
# Preface

移动范围

# insert

	gI		Insert in column 1

# line

	. current line
	+ next line
	+4 next 4'th line

# marks
marks 不是保存在register 中的，这个注意一下

	m{mark}
	:marks				list all marks
	:delm[arks]	{mark}	  safd del mark

## mark list

	'{A-Z0-9}  	全局标记
	'{a-z}  	buffer marks

Last jump

	'' `` `'	上一标记(latest jump, toggle)
	'" 			To the position when last existing the current buffer(需要开启对.viminfo信息支持)

modified && insert stop && changed

	'. 			To the position the latest modified.
	'^  `^		To the position where the cursor was the last time when Insert mode was stopped.
				This is used by the |gi| command.
	`[  `]		To the first/last character of the previously changed or yanked text.

Visual mode

	'<			The first character of the last selected Visual area in the current buffer.
	'>			The last character of the last selected Visual area in the current buffer.

sentence

	'( ')		To the start/end of current sentence
	'{ '}		To the start/end of current paragraph

## make marks

	m{mark}

## jump mark

	`{mark}		jump to pos defined by mark
	'{mark}		jump to the line head of pos defined by mark

	'{a-z}  `{a-z}
			Jump to the mark {a-z} in the current buffer.
			with sigle quote, jump to the begining of the line

	'{A-Z0-9}  `{A-Z0-9}
			To the mark {A-Z0-9} in the file where it was set (not
				a motion command when in another file). global

	g'{mark}  g`{mark}
				Jump to the {mark}, but don't change the jumplist when
				jumping within the current buffer.

# jumplist, jumps
A "jump" is one of the following commands:

	"'", "`", "G", "/", "?", "n", "N", "%", "(", ")", "[[", "]]", "{", "}", ":s", ":tag", "L", "M", "H"
	and the commands that start editing a new file.

If you make the cursor "jump" with one of these commands, the position of the cursor before the jump is
remembered.

	ctrl-o 跳到旧的jump (jump backward in insert & normal mode)
	ctrl-i/<TAB> 跳到新的jump (jump forward in normal mode)
	:ju or :jumps 查看jumplist（曾经跳过的位置列表）
	:help jumplist 查帮助

ps: <C-O> 或者 <C-I>/<TAB> 前面都可加数字(jumpid),比如

	3<C-O>
	5<C-I> or 5<TAB>

# change list

	:help changelist
	:changes 	print all change list

	g; "跳到上次修改
	g, "跳到新的修改
	`. "跳到上次修改

# Various motions

## bracket motion
matched

	% 			括号对(可通过:set matchpairs?查询支持哪些括号对)

parent

	[( ])		like %, previous / next *unmatched* parent "()"
	[{ ]}		like %, previous / next *unmatched* parent "{}"

hilight bracket:

	:showmatch

	" This comes from the pi_paren plugin
	:DoMatchParen
	:hi MatchParen cterm=reverse ctermbg=6 guibg=DarkCyan

## section motion
> http://learnvimscriptthehardway.stevelosh.com/chapters/50.html

	(	)		前/后一句首
	{	}		前/后一段首
	?{	/}		前/后一个{ }

`:h section , :h 'sections'` to see sectin defines
A section start at the nroff macros ".SH", ".NH", ".H", ".HU", ".nh" and ".sh".

	[[	]]	"{" opening braces,
			1. backward/forward secions(A)
			2. backward/forward to "{" (B)

	[]	][	"}" closing braces
			1. backward/forward secion	(A)
			2. backward/forward to "}" (B)

custom section:

	noremap <script> <buffer> <silent> ]] :call <SID>NextSection(1, 0)<cr>
	noremap <script> <buffer> <silent> [[ :call <SID>NextSection(1, 1)<cr>
	noremap <script> <buffer> <silent> ][ :call <SID>NextSection(2, 0)<cr>
	noremap <script> <buffer> <silent> [] :call <SID>NextSection(2, 1)<cr>

	function! s:NextSection(type, backwards)
		if a:type == 1
			let pattern = '\v(\n\n^\S|%^)'
			let flags = 'e'
		elseif a:type == 2
			let pattern = '\v^\S.*\=.*:$'
			let flags = ''
		endif

		if a:backwards
			let dir = '?'
		else
			let dir = '/'
		endif

		execute 'silent normal! ' . dir . pattern . dir . flags . "\r"
	endfunction

## method motion

	[m ]m		go to previous/next start of method
	[M ]M		go to previous/next end of method

## comment motion

	[/ ]/		go to previous/next end of comment

# text object, 文本对象

	aw iw "a word & a inner word后者不包含空白
	aW iW "a word 大写的字符表示特殊字符是单词的一部分
	as is "a sentence	后者不含空白及换行
	ap ip "a prograph
	a'
	a{

    "当光标在( ), [ ],< >, { }, " ", '' 内时
    "括号内
    i( or i)
    "中括号内
    i[ or i]
    i{ or i}
    "引号内
    i" i'

Tag object

	i> i< a> a<
		"<> block"

	at it
		"a tag block" like "<div> use `dat` <span> to delete div</span> </div>"

Block Motion

	aB a{
		{}
	2aB 2a{
		{{}}

	ab a(
	2ab 2a(

文件对象与操作结合：

    daw "delete a word
    cis "replece a sentence
    yi{ "yank all contents between left { and right }

	va(
	va[
	va{

### 设定单词key

	:set iskeyword=@,48-57,192-255,-,_ "@代表英文字母
	:set iskeyword-=_ #从单词key中删除下划线
