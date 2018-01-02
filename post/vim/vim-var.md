---
layout: page
title:
category: blog
description:
---
# Preface
本文会系统描述vim 的语法，如果想了解具体选项和操作技巧，参考我的vim 笔记

主要参考 [book]:
http://learnvimscriptthehardway.stevelosh.com/ (中文)
http://learnvimscriptthehardway.onefloweroneworld.com/ (英文)

# Variable Scoping
>See :help internal-variables

It lists the following types:

    (nothing) In a function: local to a function; otherwise: global
    buffer-variable    b:     Local to the current buffer.
    window-variable    w:     Local to the current window.
    tabpage-variable   t:     Local to the current tab page.
    global-variable    g:     Global.
    local-variable     l:     Local to a function.
    script-variable    s:     Local to a :source'ed Vim script.
    function-argument  a:     Function argument (only inside a function).
    vim-variable       v:     Global, predefined by Vim.

## buffer var

	:let b:hello = "world"
	:echo b:hello

## vim-Variables

	v:lnum
		Line number for the 'foldexpr' |fold-expr

## define var

# var data type

## convert type

	string({expr})

## check var type

	type({expr})	The result is a Number, depending on the type of {expr}:
				Number:	    0 	:if type(myvar) == type(0)
				String:	    1
				Funcref:    2
				List:	    3
				Dictionary: 4
				Float:	    5

## check var exist

	if exists("w")
	  finish
	endif

exists:

	exists({expr})	The result is a Number, which is non-zero if {expr} is
			&option-name
			+option-name
			$ENVNAME
			*funcname
			varname
			:cmdname	Ex command: built-in command, user command or command modifier
					Returns:
					1  for match with start of a command
					2  full match with a command
					3  matches several user commands
			:2match
						The |:2match| command.
			:3match
						The |:3match| command.
			#event
						autocommand defined for this event
			#event#pattern
						autocommand defined for this event and pattern
			#group
						autocommand group exists
			#group#event
						autocommand defined for this group and event.
			#group#event#pattern
						autocommand defined for this group, event and pattern.
			##event
						autocommand for this event is supported.

Explain:

	:finish "like function return"
	:x :exit 	update and exit
			Like ":wq", but write only when changes have been

## number

	echo 0xff
	echo 017	"15
	echo 019	"19

### caculate

	let a=a+1

### float:
>  :help floating-point-precision
>  :help Float

	echo 10.2
	echo 15.45e-2
	echo 15.45e2

operator

	echo 5%2	"1
	echo 5/2 	"2
	echo 5-2 	"3
	echo 5+2 	"7
	echo 5/2.0 	"2.5

### bit operator

	and(12,4) 4
	or(0x01,0x10)
	xor(x,y)
	pow(x,y)

### convert string to number

	:echom "hello" + 10		"10
	:echom "10hello" + 10	"20
	:echom "hello10" + 10	"10

## String

	echo '\\'
		\\
	echo "\\"
		\
	echo 'a'		'b'
		a b
	echo 'Hilojack''s blog'
		Hilojack's blog

### match

	echo match(string, search);//return pos(start from 0, like strpos)
	echo match('abc', 'bc');//1

### stridx(strpos)
### strridx(strpos)

	:echo stridx("An Example", "Example")	     3
	:echo stridx("Starting point", "Start")    0
	:echo stridx("Starting point", "start")   -1

	strridx({haystack}, {needle} [, {start}])

### substr strpart()

	strpart(str, start, len)

	strpart("abcdefg", 3, 2)    == "de"
	strpart("abcdefg", -2, 4)   == "ab"
	strpart("abcdefg", 5, 4)    == "fg"
	strpart("abcdefg", 3)	    == "defg"

### index
> :h List,

	str[start:end]		"include end"
	str[:end]			"include end"
	str[start:]		"include end"

## substitute()

	substitute({expr}, {pat}, {sub}, {flags})
		When {flags} is "g", all matches of {pat} in {expr} are
			replaced.  Otherwise {flags} should be "".


## strip trim

	function! Strip(input_string)
		return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
	endfunction

	let new_var = Strip(var)

### string func
strlen

	:echom len("foo")
	:echom strlen("foo") 	"identical , equal

### split and join
delimiter is any one of `,`, ` `:

	echo split("one two")
	echo split("one two", " ")
		["one", "two"]

	echo join(['a', 'b'], '|')

lower or upper case

	echo tolower('abc')
	echo toupper('abc')

### concat string

	echo 'a' . 'b'
	echo 10 . 'b'		"10b
	echo 10'b'			"10 b
	echo 10.1 . 'b'		"101b
	let str='a'
	let str .= 'b'

### expr-quote
> *expr-quote*
> :help literal-string.

Note that double quotes are used.

	A string constant accepts these special characters:
	\...	three-digit octal number (e.g., "\316")
	\..	two-digit octal number (must be followed by non-digit)
	\.	one-digit octal number (must be followed by non-digit)
	\x..	byte specified with two hex numbers (e.g., "\x1f")
	\x.	byte specified with one hex number (must be followed by non-hex char)
	\X..	same as \x..
	\X.	same as \x.
	\u....	character specified with up to 4 hex numbers, stored according to the
		current value of 'encoding' (e.g., "\u02a4")
	\U....	same as \u....
	\b	backspace <BS>
	\e	escape <Esc>
	\f	formfeed <FF>
	\n	newline <NL>
	\r	return <CR>
	\t	tab <Tab>
	\\	backslash
	\"	double quote
	\<xxx>	Special key named "xxx".  e.g. "\<C-W>" for CTRL-W.  This is for use
		in mappings, the 0x80 byte is escaped.  Don't use <Char-xxxx> to get a
		utf-8 character, use \uxxxx as mentioned above.

## echo

	"string
	echo "string"

	"echo with log message
	echom "echomsg"

	"view msg
	:mes

规则：

1. `echom` 会以特殊形式打印不可见字符, `echo` 则不会：
2. `echom` 只能打印字符串

	echo "\n"
	echom "\n"

# Dictionary
> :h Dictionary

定义

	:echo {'a': 1, 100: 'foo'}
	:echo {'a': 1, 100: 'foo',}
		{'a': 1, '100': 'foo'}

## index

	let index='a'
	echo {'a':1}[index]
	echo {'a':1}.a
	echo {1:1}.1

## adding and removing

	:let foo = {'a': 1}
	:let foo.a = 100
	:let foo.b = 200
	:echo foo

	:let test = remove(foo, 'a')
	:unlet foo.b
	:echo foo
		{}
	:echo test
		100

## Dictionary Function
keys & values:

	:echo keys({'a':1, 'b':2,})
	:echo values({'a':1, 'b':2,})

get

	:echom get({'a': 100}, 'a', 'default')

has_key

	:echom has_key({'a': 100}, 'a')
	0

items

	:echo items({'a': 100, 'b': 200})
		[['a', 100], ['b', 200]]


# List(Array)
> :h List

	:echo ['foo', [3, 'bar']]
	:let list=['foo', [3, 'bar']]

	# swap
	let [a,b] = [1,2]

## index

	:echo ['foo', [3, 'bar']][0]
	list[-1]
	list[start:end]		"include end"
	list[:end]			"include end"
	list[start:]		"include end"

	get(list, index, 'default')

## loop list

	let c = 0
	for i in [1, 2, 3, 4]
	  let c += i
	endfor
	echom c

### find index

	index(list, value)	" return -1, if there is no value found

## string list

	'abcd'[1:]
	'abcd'[:-1]	"abcd

	'abcd'[-1]	" 只有这个比较奇怪，返回空值

## concatenation

	echo ['a', 'b'] + ['c']

append list

	let arr+=[4,5,6]

## list function

	add(list, value)
	len(list)

## join

	join(foo, ',')
	echo split("one two", " ")
	echo split("one\ntwo", "\n")

## reverse

	:call reverse(list)
	:echo reverse(list)		" list will be changed

## sort

	:let l = [3,2,1]
	:echo sort(l)		"list will be changed

## map

	:echo map([1,2,3], '"> " . v:val . " <"')
		['> 1 <', '> 2 <', '> 3 <']

# deepcopy
list and dict is assigned by reference:

	let l1 = [1,2]
	let l2 = l1
	echo add(l2,3)
	echo l1

We can use deepcopy

	let l2 = deepcopy(l1)
	let l2 = deepcopy(l1, 1)	"recursively copy reference

# Var function type

## inner var

	:echo $VIMRUNTIME
	:vsplit $MYVIMRC
	:echo &shell
	:let w='abc'
	:echo w

## options var

	:set tw=80
	:let &tw = &tw + 10
	:set tw?
	:echo &tw
	:echo &wrap

### local options

	:let &l:number = 1

## Registers as Variables

	:let @a = "hello!"
	:echo @"
	:echo @+
	:echo @/	" store search word "/word"

	@/ search word
	@@ @"	default unnamed register

# Reference
- [learnvim hardway][book]

[book]: http://learnvimscriptthehardway.stevelosh.com/
