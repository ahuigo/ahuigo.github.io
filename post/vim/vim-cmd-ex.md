---
layout: page
title:
category: blog
description:
---
# Preface


# Cpture Ex Cmd output
Redirect ex command output into current buffer ...


	:redi[r][!] > {file}	Redirect messages to file {file}.
	:redi[r][!] >> {file}	Append messages to file {file}.
	:redi[r] END		End redirecting messages.  {not in Vi}

	:redi[r] @{a-zA-Z}
	:redi[r] @{a-zA-Z}>	Redirect messages to register {a-z}.
			Append to the contents of the register if its name is given uppercase {A-Z}.

	:redi[r] @*>
	:redi[r] @+>		Redirect messages to the selection or clipboard. For
	:redi[r] @*>>
	:redi[r] @+>>		Append messages to the selection or clipboard.


	:redi[r] => {var}	Redirect messages to a variable.
	:redi[r] =>> {var}	Append messages to an existing variable.

## filter cmd output

	function! Strip(input_string)
		return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
	endfunction

	function! Pipe2Shell(args)
	  let pos = stridx(a:args, '|')
	  let exCmd = strpart(a:args, 0, pos)
	  "let pattern = shellescape(Strip(strpart(a:args, pos+1)))
	  let shellCmd = Strip(strpart(a:args, pos+1))
	  redir => message
	  silent execute exCmd
	  redir END
	  if empty(message)
		echoerr "no output"
	  else
		new
		setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
		silent put=message
		exec '%!' shellCmd
	  endif
	endfunction
	command! -nargs=+ -complete=command Pipe2Shell call Pipe2Shell(<q-args>)

# External and vim command

## command shell
Syntax:

	vim [options] filelist
	-	stdin
	+[num]	put cursor to line num or last line

	+/{pat}

	+{command} or
	-c {command}
			   vim -c 'cmd1|cmd2|cmd3'
	--cmd {command}
			   Like using "-c", but the command is executed just before  process-
			   ing any vimrc file.

	-S {file}   {file}  will  be sourced after the first file has been read.  This
			   is equivalent to -c "source {file}".   {file}  cannot  start  with
			   '-'.   If {file} is omitted "Session.vim" is used (only works when
			   -S is the last argument).

    -s <scriptin>    The characters in file <scriptin> is interpreted as if you typed them , like `:source! {scriptin}`
	-w <scriptout>
		All the characters you  typed are recorded in <scriptout>(append), this file can be used with `:source`
	-W <scriptpout>
		Like -w, but existing file is overwritten.

	-u {path_to_vimrc}
		All the other initializations are skipped.
		vim -u NONE " No init file.

## external bang command
Syntax:

	# 替换式
	!{motion}{program} "program处理完了后，替换motion
	:{range}!{program} "program处理完了后，替换range

	# 插入式
	:{line}r!{program} "program处理完了后，推入到line 后

	# pipe to shell(仅:w)
	:[range]{w} !{program} "自带cmd 处理内容时，重定向文件描述符到stdin，program 读取stdin
	:{range}!{program} "自带cmd 处理内容时，重定向文件描述符到stdin，program 读取stdin

	# exec shell
	:!{program} 直接读取stdin

eg:

	#比如我想让一到５行的内容经过sort,这个命令会从normal进入到命令行
	!5Gsort<enter>
	:.,5!sort<enter>

	#!!{program} #此时motion为!代表当前行
	!!wc
	:.!wc

### pipe to external bang cmd

	:[range]w[rite] [++opt] !{cmd}
	:w !sudo tee %

## External shell
`[r]!{cmd}` parse as `!expand(cmd)`

	:!echo a%b
		same as: :exec '!'.expand('a%b')

## system

	echo system('ls')
	echo system('wc -c', stdin)
	echo system('cat', 'sth.')

## Escaping Shell Command Arguments
`shellescape()` is a shell function(即php中的`escapeshellarg`), and `expand()` is used to expand vim's special string like'<cWORD>':

	:echo shellescape("<cWORD>")
		'<cWORD>'
	:echom shellescape(expand("<cWORD>"))
	:nnoremap <leader>g :exe "grep -R " . shellescape(expand("<cWORD>")) . " ."<cr>

