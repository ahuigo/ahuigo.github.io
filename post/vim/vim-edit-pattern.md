---
layout: page
title: vim-pattern
category: blog
description: 
date: 2018-10-04
---
# Preface

# pattern

	:h pattern

## charlist
Character classes

	\s	whitespace character: <Space> and <Tab>
	\_s a whitespace (space or tab) or newline character

	\S	non-whitespace character; opposite of \s
	\d	digit:				[0-9]
	\D	non-digit:			[^0-9]
	\w	word character:			[0-9A-Za-z_]
	\W	non-word character:		[^0-9A-Za-z_]
	\x	hex digit:			[0-9A-Fa-f]
	\X	non-hex digit:			[^0-9A-Fa-f]
	\o	octal digit:			[0-7]
	\O	non-octal digit:		[^0-7]

	\i	identifier character (see 'isident' option)
	\I	like "\i", but excluding digits
	\k	keyword character (see 'iskeyword' option)
	\K	like "\k", but excluding digits
	\f	file name character (see 'isfname' option)
	\F	like "\f", but excluding digits
	\p	printable character (see 'isprint' option)
	\P	like "\p", but excluding digits
	\h	head of word character:		[A-Za-z_]
	\H	non-head of word character:	[^A-Za-z_]
	\a	alphabetic character:		[A-Za-z]
	\A	non-alphabetic character:	[^A-Za-z]
	\l	lowercase character:		[a-z]
	\L	non-lowercase character:	[^a-z]
	\u	uppercase character:		[A-Z]
	\U	non-uppercase character		[^A-Z]

	\_. any character including a newline
	\_x	where x is any of the characters above: character
			class with end-of-line included
    \%x1b

## atom

wrong:

	[$\w_]+

right:

	[$[:alnum:]_]+

	*[:alnum:]*		  [:alnum:]     letters and digits
	*[:alpha:]*		  [:alpha:]     letters
	*[:blank:]*		  [:blank:]     space and tab characters
	*[:cntrl:]*		  [:cntrl:]     control characters
	*[:digit:]*		  [:digit:]     decimal digits
	*[:graph:]*		  [:graph:]     printable characters excluding space
	*[:lower:]*		  [:lower:]     lowercase letters (all letters when
						'ignorecase' is used)
	*[:print:]*		  [:print:]     printable characters including space
	*[:punct:]*		  [:punct:]     punctuation characters
	*[:space:]*		  [:space:]     whitespace characters
	*[:upper:]*		  [:upper:]     uppercase letters (all letters when
						'ignorecase' is used)
	*[:xdigit:]*		  [:xdigit:]    hexadecimal digits
	*[:return:]*		  [:return:]	the <CR> character
	*[:tab:]*		  [:tab:]	the <Tab> character
	*[:escape:]*		  [:escape:]	the <Esc> character
	*[:backspace:]*		  [:backspace:]	the <BS> character

end of character classes:

	\e	<Esc>
	\t	<Tab>
	\r	<CR>
	\b	<BS>
	\n	end-of-line
	\~	last given substitute string
	\1	same string as matched by first \(\) {not in Vi}
	\2	Like "\1", but uses second \(\)
	\c	ignore case, do not use the 'ignorecase' option
	\C	match case, do not use the 'ignorecase' option

especially:

	^	start of line
	$	end of line
	\%^ start of file
	\%$ end of file

word boundary:

	\>单词右 \< 单词左边界

按键：

	<Up><Down><Left><Right>

### origin atom
          magic   nomagic	matches ~

    |/\%^|	\%^	\%^	beginning of file |/zero-width|		*E71*
    |/^|	^	^	start-of-line (at start of pattern) |/zero-width|
    |/\^|	\^	\^	literal '^'
    |/\_^|	\_^	\_^	start-of-line (used anywhere) |/zero-width|
    |/$|	$	$	end-of-line (at end of pattern) |/zero-width|
    |/\$|	\$	\$	literal '$'
    |/\_$|	\_$	\_$	end-of-line (used anywhere) |/zero-width|
    |/.|	.	\.	any single character (not an end-of-line)
    |/\_.|	\_.	\_.	any single character or end-of-line
    |/\<|	\<	\<	beginning of a word |/zero-width|
    |/\>|	\>	\>	end of a word |/zero-width|
    |/\zs|	\zs	\zs	anything, sets start of match
    |/\ze|	\ze	\ze	anything, sets end of match
    |/\%$|	\%$	\%$	end of file |/zero-width|
    |/\%V|	\%V	\%V	inside Visual area |/zero-width|
    |/\%#|	\%#	\%#	cursor position |/zero-width|
    |/\%'m|	\%'m	\%'m	mark m position |/zero-width|
    |/\%l|	\%23l	\%23l	in line 23 |/zero-width|
    |/\%c|	\%23c	\%23c	in column 23 |/zero-width|
    |/\%v|	\%23v	\%23v	in virtual column 23 |/zero-width|

### hexcode
The full table of character search patterns includes some additional options: 'sssssssss 1'

    \%u20ac
    \%d match specified decimal character (eg \%d123)
    \%x match specified hex character (eg \%x2a)
    \%o match specified octal character (eg \%o040)
    \%u match specified multibyte character (eg \%u20ac)
    \%U match specified large multibyte character (eg \%U12345678)

### collection*

    [0-9]

### in replace
一般情况下`\r\n`分别代表回车与换行，但是在`:%s/pattern/replace` 中的replace

replace 比较特别：

    \n 代表ascii 0(^@)
        (相当于按<c-v><c-@>, 或者 CTRL-V 000)
    \r 代表\n
    ^M  在replace中居然表示\n
        不表示<c-v><c-m>, <c-v>013


## multi
default nomagic, need `\` backslash 

	    'magic'        'nomagic'    matches of the preceding atom ~
	\*	0 or more	    as many as possible
	\+	1 or more	    as many as possible (*)
	\=	0 or 1		    as many as possible (*)
	\?	0 or 1		    as many as possible (*)

	\{n,m}	n to m		as many as possible (*)
	\{n}	n		    exactly (*)
	\{n,}	at least n	as many as possible (*)
	\{,m}	0 to m		as many as possible (*)
	\{}	0 or more	    as many as possible (same as *) (*)

	\{-n,m}	n to m		as few as possible (*)
	\{-n}	n		    exactly (*)
	\{-n,}	at least n	as few as possible (*)
	\{-,m}	0 to m		as few as possible (*)
	\{-}	0 or more	as few as possible (*)

    \(\) 这个得全部转义 \{\} 只需要左括号转义


## magic, very magic,nomagic
:h magic, 默认是magic

Vim 中的 "magic" 模式决定了正则表达式中特殊字符的行为。Vim 提供了四种 "magic" 模式：

    \v (very magic)：在这种模式下，大多数字符都有特殊含义，只有少数字符被视为普通字符。这种模式最接近 Perl 和其他现代正则表达式语言的行为。
    \m (magic)：这是 Vim 的默认模式。在这种模式下，一些字符有特殊含义，而其他字符被视为普通字符。
    \M (nomagic)：在这种模式下，几乎所有字符都被视为普通字符，只有少数字符有特殊含义。
    \V (very nomagic)：在这种模式下，所有字符都被视为普通字符，除非它们被转义。

总结一下

    Use of "\v" means that after it, all ASCII characters except '0'-'9', 'a'-'z',
    'A'-'Z' and '_' have special meaning: "very magic"

    Use of "\V" means that after it, only a backslash and the terminating
    character (usually / or ?) have special meaning: "very nomagic"


like perl and php:

	+*?(){}|    is very magic
	<>          is very magic
	&           is very magic
        /\v<(word|word2)>
	:execute 'normal! gg/\vfor .+ in .+:' . "\<cr>"


## zeor-width assert

	\@>	1, like matching a whole pattern (*)
	\@=	nothing, requires a match |/zero-width| (*)
	\@!	nothing, requires NO match |/zero-width| (*)
	\@<=	nothing, requires a match behind |/zero-width| (*)
	\@<!	nothing, requires NO match behind |/zero-width| (*)

Example:

	\(foo\)\@<!bar		any "bar" that's not in "foobar"
	\(\/\/.*\)\@<!in	"in" which is not after "//"

	\(my\)\@<!hilo\(jack\)@!		any "hilo" that has no 'my' prefix and 'jack' suffix

### reset whole match

	\zs	Matches at any position, and sets the start of the match there: The
		next char is the first char of the whole match. |/zero-width|
		Example: >
			/\( \zsFab\)\{3}
		<	Finds the third occurrence of "Fab".

	\ze	Matches at any position, and sets the end of the match there: The
		previous char is the last char of the whole match. |/zero-width|

## logic

	/pat1\|pat2
	/pat1\&pat2

	/\vpat1&pat2

# compare with perl

	Capability			in Vimspeak	in Perlspeak ~
	----------------------------------------------------------------
	force case insensitivity	\c		(?i)
	force case sensitivity		\C		(?-i)
	backref-less grouping		\%(atom\)	(?:atom)
	conservative quantifiers	\{-n,m}		*?, +?, ??, {}?
	0-width match			atom\@=		(?=atom)
	0-width non-match		atom\@!		(?!atom)
	0-width preceding match		atom\@<=	(?<=atom)
	0-width preceding non-match	atom\@<!	(?<!atom)
	match without retry		atom\@>		(?>atom)

Here two example are equal

	:%s/\%(hilo\)-\(jack\)/-\1-/g	"\%(\) without counting it as a sub-expression.
	:%s/\(hilo\)-\(jack\)/-\2-/g

## reference

	/\v(word) &
	/\v(word) \1

	" They are same
	:%s/\(word\)/--&--/g
	:%s/\(word\)/--\1--/g

	:%s/\(word\)/--\&--/g  "& is iteral

一般情况下\r\n分别代表回车与换行，但是在`:%s/pattern/replace` 中的replace，replace 只能用'\r'表示换行，'\n'表示回车

	:%s/\([^-]*\)-\(.*\)/\2 \r \1/gc   "vim中的替换也可以用到正则反引用\2\1


# search 搜索
高亮/搜索时定位/循环搜索时的配置

    " 大小写不敏感匹配
    :set ignorecase 
    " 当搜索的字母只有小写时, 就大小写敏感. 否则,就大小写不敏感
    :set smartcase

	#高亮搜索关键字
	:set hls 或 :set hlsearch
	:nohlsearch "限本次搜索不高亮
    #真正的撤消搜索 clearmatch clear search: 有这几种
    :noremap <F3> :let @/ = ""<CR>
    :set nohlsearch
    :set hlsearch!
    :noh

	#还未完全键入字串时就能找到目标
	:set is
    :set incsearch

	#默认是到达文件尾后回到文件头
	:set ws 
    :set wrapscan
	#到达文件尾就停止搜索
	:set nows
    :set nowrapscan

## 普通搜索(common search）
1. /pattern :/pattern/offset 正向搜索 （可以用n N正向反向重复)
1. /pattern/e "The e stands for "end" of the matched pattern.
1. ?pattern?e :?pattern?offset 反向搜索 （可以用n N反向正向重复)
1. `*` 搜索光标所处的单词
2. fx　搜索一个字符 Fx　反向搜索字符（行内）
tx/Tx　搜索一个字符(相当于Fx/fx，可以用`;`,`,`实现正向反向重复）

## search()
`:h search()` return lnum

	onoremap <script> <buffer> af :call <SID>CurrentFunction()<cr>
	vnoremap <script> <buffer> af :call <SID>CurrentFunction()<cr>
	function! s:CurrentFunction()
		if search('\v^(\t|    )\w.*function \w+\([^\)]*\)\_s*\{', 'b') > 0
			"exe 'silent normal' '?\v^(\t|    )\w.*function \w+\([^\)]*\)\_s*\{'."\r"
			exe 'normal' "\<esc>".'V/\v^(\t|    )\}/'."\r"
		endif
	endfunction

### searchpos()

	:let [lnum, col] = searchpos('searhpos')

## search plugin

### easymotion
这个插件扩展了fx/tx 的功能, 我觉得map成f 触发比较好

	"map <Leader><Leader> <Plug>(easymotion-prefix)
	nnoremap f <Plug>(easymotion-prefix)

## ex-gsearch
这是一个exVim项目用的search插件, 基于idutils

    <leader>gg  Global search current word under cursor, show the result in ex-gsearch window.
    <leader>]   Search the defines and declarations of current word under cursor, show the result in ex-tags window.
    <leader>sg  List all defines and declarations of current word, show the result in ex-symbole window.
    :GS <word>  Global search
	:SUB a/b	Global replace(new version)

## vimgrep and grep

	"搜索当前目录下的*.txt
	:vimgrep pattern *.txt
	:vimgrep /pattern/ *.txt
	:vimgrep /\<word\>/g *.c
	:vimgrep /\<word\>/g *.c
	"搜索当前子目录下的 */*.txt
	:vimgrep pattern */*.txt
	"递归搜索当前目录下的 */*.txt
	:vimgrep pattern **/*.txt

	:vimgrep {search} {infiles}
	:lvimgrep {search} {infiles}
			Same as ":vimgrep", except the location list for the
			current window is used instead of the quickfix list.

	:grep {search} {infiles}
	:lgrep {search} {infiles}
		When 'grepprg' is "internal" this works like |:vimgrep|.
		Note that the pattern needs to be enclosed in separator characters then.
		set grepprg?

多文件替换：

	"将要扫描的文件加入argument list
	:args **/*.txt **/*.cpp
	"在参数列表中的文件中执行替换 并保存上
	:argdo %s/hate/love/gc | update

Refer to:
http://www.vimer.cn/2009/10/vimgvim%E5%AE%9E%E7%8E%B0%E5%A4%9A%E6%96%87%E4%BB%B6%E7%9A%84%E6%9F%A5%E6%89%BE%E5%92%8C%E6%9B%BF%E6%8D%A2.html

# hilight match

	:mat[ch] {group} /{pattern}/

Define a pattern to highlight in the current window.  It will
be highlighted with {group}.  Example: >


	:highlight MyGroup ctermbg=green guibg=green
	:match MyGroup /TODO/

	"system Error"
	:match Error /\v.../

	"clear match"
	:match none

Instead of `//` any character can be used to mark the start and
end of the `{pattern}`.  Watch out for using special characters,
such as '"' and '|'.