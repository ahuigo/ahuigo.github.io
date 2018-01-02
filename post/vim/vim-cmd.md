---
layout: page
title:
category: blog
description:
---
# Preface

# autocmd
Syntax:

	:au[tocmd] [group] {event} {pat} [nested] {cmd}
			Add {cmd} to the list of commands that Vim will
			execute automatically on {event} for a file matching
			{pat} |autocmd-patterns|.

	:autocmd BufNewFile * :write
         ^          ^ ^
         |          | |
         |          | The command to run.
         |          |
         |          A "pattern" to filter the event.
         |
         The "event" to watch for.

## event
> :help autocmd-events

### io event

	BufNewFile
	BufRead
	BufWrite
	BufWritePre "same as BufWrite
	BufWritePre,BufRead

Example:

	:autocmd BufWritePre *.html :normal gg=G
	:autocmd BufWritePre *.html normal gg=G

### FileType event
excute when filetype is set or vim starts

	:autocmd FileType javascript nnoremap <buffer> <localleader>c I//<esc>
	:autocmd FileType python nnoremap <buffer> <localleader>c I//<esc>

Refer to: [vim-filetype](/p/vim-filetype)

## pattern

	*
	*.txt
	javascript

multi pattern:

	:autocmd FileType c,cpp  map <buffer> <leader><space> :w<cr>:make<cr>

## group
> :help autocmd-groups

To solove the problem: duplicated autocmd group, we can use `autocmd!` to clear current group

	:augroup testgroup
	:    autocmd!
	:    autocmd BufWrite * :echom "Cats"
	:    autocmd BufWrite * :echom "Dogs"
	:augroup END

Vim automatically wraps the contents of ftdetect/*.vim files in autocommand groups for you, so you don't need to use an autocommand group like we usually would.

## specical characters
*specical characters* in the `:autocmd` arguments are *not expanded*. The only excetion is `sfile`:

	:au BufNewFile,BufRead *.html so <sfile>:h/html.vim

# command

## command exist

	echo has('autocmd')

## execute command

	:execute "echom 'Hello, world!'"

multi args:

	:exec arg1   arg2 ...
		:arg1 arg2 arg3 will be concat to command seperated by "<space>"
	:exe "echom" "'Hello," "world!'"

It will parse such args:

	function: eg. expand(),etc.

	:exec "!echo" expand('%:')

## multi command

	:cmd1|cmd2|cmd3
	:!shell cmd only
		:!ls | wc -l

## silent
To disalbe command's output.

	:silent echo "abc"
	:silent !echo "abc"
	:silent execute "normal! .."

## normal command

	:normal gg=G

	"If then [!] is given, mapping will not be used
	:normal! gg=G

normal does not recognize special charactors, but `execute` with *double quotes* can!

	"wrong
	:normal! gg/a<cr>
	:execute 'normal! gg/a<cr>'
	:execute "normal! gg/a<cr>"
	:execute 'normal! gg/a\r'

	"right
	:execute "normal! gg/a\<cr>"
	:execute "normal! gg/a\r"

Refer to `:h expr-quote` and [vim-var](/p/vim-var)



# user defined command
The rules of user defined commmand

1. User-defined Command must start with an `upppercase letter`, to avoid confusion with builtin commands. Exceptions are these builtin commands:
	:Next
	:X
2. Fllowing letter and digits (exclude `_`)
	:E1 	ok
	:EA 	ok
	:E_ 	wrong

## list user defined commands

	:com[mand] {cmd}	List all user-defined command that start with {cmd}

When `'verbose'` is non-zero, listing a command will also display where it was
last defined. Example:

    :verbose command TOhtml
	Name	    Args Range Complete  Definition ~
	TOhtml	    0	 %		 :call Convert2HTML(<line1>, <line2>) ~
	    Last set from /usr/share/vim/vim-7.0/plugin/tohtml.vim ~

See `|:verbose-cmd|` and `:h 'vbs'` for more information.

## define command

	:com [{attr}...] {cmd} {rep}
			Define a user command.  The name of the command is
			{cmd} and its replacement text is {rep}.  The command's
			attributes (see below) are {attr}.

### args
There are a number of attributes, split into four categories:

1. argument handling,
2. completion behavior,
3. range handling,
4. special cases.

#### Argument handling
Argument:

	-nargs=0    No arguments are allowed (the default)
	-nargs=1    Exactly one argument is required, it includes spaces
	-nargs=*    Any number of arguments are allowed (0, 1, or many),
		    separated by white space
	-nargs=?    0 or 1 arguments are allowed
	-nargs=+    Arguments must be supplied, but any number are allowed

##### Separated character:

1. Arguments are considered to be separated by (unescaped) `spaces or tabs` in this
context.
2. Except when there is `one argument`, then the white space is part of the argument.

##### Argument expressions:
that `arguments` are used as `text`, `not as expressions`. Except functions

Specifically, `s:var` will use the script-local variable in the script where the command was
`defined`, not where it is invoked!  Example:

    script1.vim: >
	:let s:error = "None"
	:command -nargs=1 Error echoerr <args>

	script2.vim: >
	:source script1.vim
	:let s:error = "Wrong!"
	:Error s:error

Executing `script2.vim` will result in `None` being echoed.

> Calling a function may be an alternative.

#### Completion behavior
By default, the arguments of user defined commands do not undergo completion.
However, by specifying one or the other of the following attributes, argument
completion can be enabled:

	-complete=augroup	autocmd groups
	-complete=buffer	buffer names
	-complete=behave	:behave suboptions
	-complete=color		color schemes
	-complete=command	Ex command (and arguments)
	-complete=compiler	compilers
	-complete=cscope	|:cscope| suboptions
	-complete=dir		directory names
	-complete=environment	environment variable names
	-complete=event		autocommand events
	-complete=expression	Vim expression
	-complete=file		file and directory names
	-complete=file_in_path	file and directory names in |'path'|
	-complete=filetype	filetype names |'filetype'|
	-complete=function	function name
	-complete=help		help subjects
	-complete=highlight	highlight groups
	-complete=history	:history suboptions
	-complete=locale	locale names (as output of locale -a)
	-complete=mapping	mapping name
	-complete=menu		menus
	-complete=option	options
	-complete=shellcmd	Shell command
	-complete=sign		|:sign| suboptions
	-complete=syntax	syntax file names |'syntax'|
	-complete=syntime	|:syntime| suboptions
	-complete=tag		tags
	-complete=tag_listfiles	tags, file names are shown when CTRL-D is hit
	-complete=user		user names
	-complete=var		user variables
	-complete=custom,{func} custom completion, defined via {func}
	-complete=customlist,{func} custom completion, defined via {func}

> Note: That some completion methods might expand environment variables.

##### Custom completion
It is possible to define customized completion schemes via the `custom,{func}`
or the `customlist,{func}` completion argument.  The `{func}` part should be a
function with the following signature: >

	:function {func}(ArgLead, CmdLine, CursorPos)
		ArgLead		the leading portion of the argument currently being completed on
		CmdLine		the entire command line
		CursorPos	the cursor position in it (byte index)


- `custom` argument, the function should return the completion candidates `one per line` in a newline separated string
- `customlist` argument, the function should return the completion candidates as `vim list`

	com -complete=custom,ListUsers -nargs=1 Finger !finger <args>
	fun ListUsers(A,L,P)
		return system("cut -d: -f1 /etc/passwd")
	endfun

#### 3. Range handling,
By default, `user-defined` commands do not accept a line number range.

However, it is possible to specify that the command does take a range,
	either in the `line number` position (`-range=N`, like the `|:split|` command)
	or as a `"count"` argument (`-count=N`, like the `|:Next|` command).

Possible attributes are:

	-range	    Range allowed, default is current line
	-range=%    Range allowed, default is whole file (1,$)
	-range=N    A count (default N) which is specified in the line
		    number position (like |:split|); allows for zero line number.
	-count=N    A count (default N) which is specified either in the line
		    number position, or as an initial argument (like |:Next|).
		    Specifying -count (without a default) acts like -count=0

Note that `-range=N` and `-count=N` are `mutually exclusive` - only one should be specified.

It is possible that the special characters in the range like `.`, `$` or `%` which
by default correspond to the current line, last line and the whole buffer,

Possible `:command-addr` values are:

	-addr=lines		Range of lines (this is the default)
	-addr=arguments		Range for arguments
	-addr=buffers		Range for buffers (also not loaded buffers)
	-addr=loaded_buffers	Range for loaded buffers
	-addr=windows		Range for windows
	-addr=tabs		Range for tab pages

#### Special cases
There are some special cases as well:

	-bang	    The command can take a ! modifier (like :q or :w)
	-bar	    The command can be followed by a "|" and another command.
		    A "|" inside the command argument is not allowed then.
		    Also checks for a " to start a comment.
	-register   The first argument to the command can be an optional
		    register name (like :del, :put, :yank).
	-buffer	    The command will only be available in the current buffer.

In the cases of the -count and -register attributes, if the optional argument
is supplied, it is removed from the argument list and is available to the
replacement text separately.

#### Replacement text
To avoid the replacement use `<lt>` in place of the initial `<`.  Thus to include "`<bang>`" literally use "`<lt>bang>`".

The valid escape sequences are

						*<line1>*
	<line1>	The starting line of the command range.
						*<line2>*
	<line2>	The final line of the command range.
						*<count>*
	<count>	Any count supplied (as described for the '-range'
		and '-count' attributes).
						*<bang>*
	<bang>	(See the '-bang' attribute) Expands to a ! if the
		command was executed with a ! modifier, otherwise
		expands to nothing.
						*<reg>* *<register>*
	<reg>	(See the '-register' attribute) The optional register,
		if specified.  Otherwise, expands to nothing.  <register>
		is a synonym for this.
						*<args>*
	<args>	The command arguments, exactly as supplied (but as
		noted above, any count or register can consume some
		of the arguments, which are then not part of <args>).
	<lt>	A single '<' (Less-Than) character.  This is needed if you
		want to get a literal copy of one of these escape sequences
		into the expansion - for example, to get <bang>, use
		<lt>bang>.

#### q-args(signle)
If the first two characters of an escape sequence are `q-` (for example, `<q-args>`)
then `the value is quoted` in such a way as to make it a valid value for use in an expression.

> This uses the argument as one single value.

#### f-args(multi)
To allow commands to pass their arguments on to a `user-defined function`,
there is a special form `<f-args> ("function args")`.

This splits the command arguments at `spaces and tabs`, quotes each argument individually, and the
`<f-args>` sequence is replaced by the `comma-separated list of quoted arguments`.

See the Mycmd example below.

	command		   <f-args> ~
	XX ab		   'ab'
	XX a\b		   'a\b'
	XX a\ b		   'a b'
	XX a\  b	   'a ', 'b'
	XX a\\b		   'a\b'
	XX a\\ b	   'a\', 'b'
	XX a\\\b	   'a\\b'
	XX a\\\ b	   'a\ b'
	XX a\\\\b	   'a\\b'
	XX a\\\\ b	   'a\\', 'b'

Examples >

	" Delete everything after here to the end
	:com Ddel +,$d

	" Rename the current buffer
	:com -nargs=1 -bang -complete=file Ren f <args>|w<bang>

	" Replace a range with the contents of a file
	" (Enter this all as one line)
	:com -range -nargs=1 -complete=file
	 Replace <line1>-pu_|<line1>,<line2>d|r <args>|<line1>d

	" Count the number of lines in the range
	:com! -range -nargs=0 Lines  echo <line2> - <line1> + 1 "lines"

	" Call a user function (example of <f-args>)
	:com -nargs=* Mycmd call Myfunc(<f-args>)

When executed as: >

	:Mycmd arg1 arg2

This will invoke: >

	:call Myfunc("arg1","arg2")

	:" A more substantial example
	:function Allargs(command)
	:   let i = 0
	:   while i < argc()
	:	  if filereadable(argv(i))
	:	     execute "e " . argv(i)
	:	     execute a:command
	:      endif
	:      let i = i + 1
	:   endwhile
	:endfunction
	:command -nargs=+ -complete=command Allargs call Allargs(<q-args>)

The command Allargs takes any Vim command(s) as argument and executes it on all
files in the argument list.  Usage example (note use of the "e" flag to ignore
errors and the "update" command to write modified buffers): >

	:Allargs %s/foo/bar/ge|update

This will invoke: >

	:call Allargs("%s/foo/bar/ge|update")

When the user invokes the user command, it will run in the context of the script it was defined in.
This matters if `|<SID>|` is used in a command.

## delete

	"clear all
	:comc :comclear

	"delete the user-defined command {cmd}
	:delc {cmd}

# Multi commands  one line
see [/p/vim-script](/p/vim-script#if)

	:if 0
	:    echom "if"
	:elseif "nope!"
	:    echom "elseif"
	:else
	:    echom "finally!"
	:endif

	if 1| echo "true" | endif

# Reference
- [learnvim]

[learnvim]: http://learnvimscriptthehardway.stevelosh.com/chapters/12.html
