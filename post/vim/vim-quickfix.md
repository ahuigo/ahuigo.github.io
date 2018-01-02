---
layout: page
title:	
category: blog
description: 
---
# Preface
[vim-quickfix](/p/vim-quickfix)
> Refer to: http://easwy.com/blog/archives/advanced-vim-skills-quickfix-mode/

# quickfix 

quickfix 是一个位置列表(`:h location-list`)，:make 或者 :grep 或者cscope 命令都可以产生这个位置列表，方便我们做跳转

## create location 

via make:

	"config make, make is default command
	:set makeprg=gcc\ -Wall\ -ohello\ e.c 

via inner vimgrep

	:vim[grep][!] /{pattern}/[g][j] {file} ...
	:vim[grep][!] {pattern} {file} ...
	:vimgrep word **/*.c
	:vimgrep /\<word\>/g **/*.c

via outer grep:

	:set grepprg=grep
	:grep word **/*.c

## use quickfix

jump

    :cp                跳到上一个错误 ( :help :cp )
    :cn                跳到下一个错误 ( :help :cn )

    :cpfile            previous error file
    :cnfile            next error file

    :col               到前一个旧的错误列表 ( :help :col )
    :cnew              到后一个较新的错误列表 ( :help :cnew )
    :cfirst            first error
    :clast				last error

list

    :cl              list error list as msg
    :cw              Open the quickfix window when there are recognized errors.
	:copen			"打开quickfix, 即使没能错误列表
	:cclose
	<enter>		jump to file

display

    :cc [nr]            display error in window

use location list for current window instead of quickfix list:

	:lgrep word **/*.c
	:lv word **/*.c
	:lw "like :cw
	:lnext /:lp
	:lnewer /:lolder

    :lvimgrep /<c-r>=expand("<cword>")<cr>/ %

> quickfix list is global and we can not have more one at a time
> location list is local for current window and we can have as many locations as windows.

# grep
grep will replace `<cword>` with "the word under cursor"
grep will replace `<cWORD>` with "the long WORD under the cursor"

	:nnoremap <leader>g :grep -R <cword> .<cr>
	:grep -R <cword> .

## Escaping Shell Command Arguments
shellescape() is a shell function(即php中的`escapeshellarg`), and `expand()` is used to expand vim's special string like'<cWORD>':

	:echo shellescape("<cWORD>") 
		'<cWORD>'
	:echom shellescape(expand("<cWORD>"))
	:nnoremap <leader>g :exe "grep -R " . shellescape(expand("<cWORD>")) . " ."<cr>

