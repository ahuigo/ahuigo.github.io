---
layout: page
title:
category: blog
description:
---
# Preface

# debug

## verbose

	:set verbose=1
	:set verbose=15
	:verbose com {cmd}

see `:h 'vbs'`

## copy command
copy commands:

	"+y

execute commands:

	@+

## log typed characters

	vim -w vim_typed.bin a.txt
	vim -W vim_typed.bin a.txt "overwritten

> For about shell typed characters, refer to [shell.md](/shell.md)

# control expression

## loop

## loop list

	for i in [1, 2, 3, 4]
	  let c += i
	endfor

## while loop

	while c <= 4
	  let c += 1
	endwhile

## if

	:if ! 0
	:    echom "if"
	:elseif ! "nope!"
	:    echom "elseif"
	:else
	:    echom "finally!"
	:endif

	if 1| echo "true" | endif

if string

	:echom "hello" + 10		"10
	:echom "10hello" + 10	"20
	:echom "hello10" + 10	"10

	if ! "something"
	    echom "false"
	endif

	if "123"
	    echom "true"
	endif

## comment expression

	:" This is a comment
	:imap a b | " This is a comment
	:imap a b \| |" This is a comment

## comparision expression
> Read :help expr4 to see all the available comparison operators.

		use 'ignorecase'    match case	   ignore case ~
	equal			==		==#		==?
	not equal		!=		!=#		!=?
	greater than		>		>#		>?
	greater than or equal	>=		>=#		>=?
	smaller than		<		<#		<?
	smaller than or equal	<=		<=#		<=?
	regexp matches		=~		=~#		=~?
	regexp doesn't match	!~		!~#		!~?
	same instance		is		is#		is?
	different instance	isnot		isnot#		isnot?

example

	echo 30 > 1 		"1
	echo "foo"=="bar"	"0
	echo ""==0			"1

case ignore sensitive(default sensitive)

	"set ignorecase
	echo "A" == 'a'		"1

no matter what user set:

	"case sensitive
	echo 'A'==#'a'		"0
	"case insensitive
	echo 'A'==?'a'		"1

## pattern expression

	echo getline(a:lnum) =~? '\v^\s*$'

# try catch

	try
		...
	catch /{pattern1}/
		...
	catch /E227/
		...
	finally
		...
	endtry

catch:

	:catch	" same as catch /.*/

example

    try
      nnoremap <unique> <silent> <leader>h1 :EasyhlWord 1<CR>
    catch /E227/
	finally
		echo "cleanup"
    endtry

# Function

## Define Function
1. `[!]` is required to overwrite an existing function
2. funcName must start with capital or contain colon
3. It cannot be combined to one line.
4. `:return :retu` default return`0`

Function must start with a capital letter or `:`,

	function Meow(name)
	  echo a:name
	  return "Meow String!"
	endfunction

### local script function
> :h <SID>
> http://learnvimscriptthehardway.stevelosh.com/chapters/34.html

 "s:" can be prepended to the name to make it local to the script.

	nnoremap <leader>g :set operatorfunc=<SID>echo<cr>g@
	function! s:echo(type)
		echo 'abc'
	endfunction

## Call Function

	:call Meow("hilo")
	:echo Meow("hilo")
		print result
	:echo my:echo("v")

### g@{motion}

	g@{motion}
		call function defined by `set operatorfunc`

Example:

	nnoremap <leader>g :set operatorfunc=GrepOperator<cr>g@

	function! GrepOperator(type)
		echom "Test"
	endfunction

On visual mode, you don not need `g@`:

	vnoremap <leader>g :<c-u>call GrepOperator(visualmode())<cr>

> visualmode() return the last type of visual mode used:
	"v" for characterwise, "V" for linewise, and a Ctrl-v character for blockwise.

## Varargs:
`a:var` can not be modified!

	function Varg(...)
	  echom a:0
	  echom a:1
	  echom a:2
	  echo '------'
	  echo a:000
	endfunction
	:call Varg("a", "b")

Result, `a:0` is `number of extra args`, `a:000` is a list contain extra args:

	2
	a
	b
	------------
	['a', 'b']

use varargs together with regular arguments too

	function Varg2(foo, ...)
	  echom a:foo
	  echom a:0
	  echom a:1
	  echo a:000
	endfunction
	call Varg2("a", "b", "c")

Result:

	a
	2
	b
	['b', 'c']

# 脚本文件

## load script

	:source %
	:source file

### autoload

	:call somefile#Hello()

If not loaded, Vim will look for a file called `autoload/somefile.vim` in your `runtimepath` directory (and any Pathogen bundles).

	function somefile#Hello()
		" ...
	endfunction

`autoload/myplugin/somefile.vim`:

	:call myplugin#somefile#Hello()

## 查看脚本

	:scrip	:scriptnames 查看加载的脚本
	:version 查看编译项、配置文件

	:echo $VIMRUNTIME
	:vsplit $MYVIMRC

	:set runtimepath?

### 全局plugin

	~/.vim/plugin/
	$VIMRUNTIME/macros

### 文件类型插件filetype plugin

	$VIMRUNTIME/ftplugin

## 文件类型(plugintype detection)
开启插件检测：

	"enable file type detection
	:filetype on

	"enable loading the plugin files for specific file types with:
	:filetype plugin on

	"enable loading the indent file for specific file types with:
	:filetype plugin indent on

