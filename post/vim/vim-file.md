---
layout: page
title: vim-file
category: blog
description: 
date: 2018-10-04
---
# Preface

- filetype
- Directory
- file
- file open and exit

# Filetype
Overview:					*:filetype-overview*

	command				detection	plugin		indent ~
	:filetype on			on		unchanged	unchanged
	:filetype off			off		unchanged	unchanged
	:filetype plugin on		on		on		unchanged
	:filetype plugin off		unchanged	off		unchanged
	:filetype indent on		on		unchanged	on
	:filetype indent off		unchanged	unchanged	off
	:filetype plugin indent on	on		on		on
	:filetype plugin indent off	unchanged	off		off

To see the current status, type: >

	:filetype

If the ":syntax on" command is used, the file type detection is installed too(implied).  There is no need
to do ":filetype on" after ":syntax on".

## set get filetype
:setf :setfiletype

	au! BufNewFile,BufRead *.bat,*.sys setf dosbatch

get filetype:

	:set filetype?
	filetype=mkd
	filetype=javascript
	filetype=python

# Directory

## Directory Manager
nerdtree 是一个非常强大的文件管理插件

以下命令都可以调用插件查看文件目录，
你看上方会得到相应的帮助。
其中-会返回上一级，x 会启动文件管理器，D会删除文件

	:Sex [dir]//切割窗口并浏览文件
	:Vex	split vertical
	:edit dir  #dir可以为ftp://
	:Explore dir #dir可以为ftp://
	:Te dir #以tab打开一个dir
	ctrl+o "非常有用的，返回上一个位置:

### 当前目录
你可以查看当前目录

	:pwd :call getcwd()
	#在当前窗口(lcd)下设置的当前目录
	:lcd /etc
	#重设所有窗口的当前目录（除了使用lcd的窗口）
	:cd /etc
		:cd 		change to HOME directory
		:cd %:h		change to directory of current file
		:cd -		change to previous current directory


## Path
> :h expand()
> :h filename-modifiers


	:echom expand('%')					"relative file path
	:echom expand('%:p')				"absolute file path
	:echom expand('%:h')				"relative file directory .
	:echom expand('~/.vimrc')			"absolute path
	:echom fnamemodify('foo.txt', ':p') "Absolute path

:h filename-modifiers:

	:. reduce file name to current directory
	:r root of the file name(without extension)
	:e extension of file name

    :p file full path
	:% file relative path
    :inoremap <D-V> <ESC>:r!echo '%:t:r'<CR>

### buffer
Register `%` contains the name of the current file,
and register `#` contains the name of the alternate file.
string `~` replace HOME

	:echo @% 				def/my.txt	directory/name of file (relative to the current working directory of /abc)
	:echo expand('%:t') 	my.txt		name of file ('tail')
	:echo expand('%:t:r') 	my			name of filename (without extension)
	:echo expand('%:p') 	/abc/def/my.txt	full path
	:echo expand('%:p:h')	/abc/def	directory containing file ('head')
	:echo expand('%:p:h:t')	def			First get the full path with :p (/abc/def/my.txt),
										then get the head of that with :h (/abc/def),
										then get the tail of that with :t (def)
### curren excuted vim's path
like python `__file__`:

    expand('<sfile>')
    expand('<sfile>:p:h')

### wildcard
> :h wildcard

	?	matches one character
	*	matches anything, including nothing
	**	matches anything, including nothing, recurses into directories
	[abc]	match 'a', 'b' or 'c'

Example: >

	:n **/*.txt

When non-wildcard characters are used these are only matched in the first
directory.  Example: >

	:n /usr/inc**/*.h

### filename

	fnameescape('./a b')
		./a\ b
	simplify("./dir/.././/file/") == "./file/"
	simplify("./a b")
		./a b

## list file

	:echo glob('~/*')

	:echo globpath('.', '*')
	:echo globpath('.', '*.txt')
	:echo globpath('.', '**')		"recursively list
	:echo globpath('.', '**/*.txt')	"recursively list

return list

	:echo split(globpath('.', '*'), "\n")

# File

## file attribute

	filereadable(expand('~/.vimrc'))
	exec 'source '.fnameescape('~/.vimrc')

## line num

	line('$')

## getline

	getline({lnum}) "get line of lnum
	getline('.')

## setline

	let result = system('cat', 'sth.')
	call setline(line('.'), getline('.') . ' ' . result)

## indent

	function! IndentLevel(lnum)
		return indent(a:lnum) / &shiftwidth
	endfunction

## append
insert string after line {lnum}

	setlocal buftype=nofile
    call append(lnum, split('a,b', ','))

:read

	:[lnum]r <file>
	:[lnum]r !cmd

# Open, save, exit

	noremap <C-q> :qa<CR>

## Open

	:e <file>
	:f[ile] <new_file_name>

> refer `# Window`

### argument file

	argc()				Number	number of files in the argument list
	argv( {nr})			String	{nr} entry of the argument list

### Read Only 只读

	vim -R a.txt　#加!也可以修改
	vim -M a.txt #不可编辑
	//也可以临时更改为可读
	:set write
	:set modifiable

### Encrypt 加密

	#打开加密文件
	:vim -x a.txt
	:X #设置加密key
	:set key= #取消加密key
	#加密编辑时，不产生交换文件
	vim -x -n a.txt or :set noswapfile

### Binary File 二进制文件

	vim -b a.mp3
	#以十六进制显示
	:%!xxd or :set display=uhex

## Write
append(without change reload)

	:[range]w >>
	:[range]w >> {file}

## Exit

	ZZ 保存退出
	ZQ 不保存退出

保存

	:wa 全部保存
	:wqa

write when changes exist

	:x :xit :exit

不保存

	:q! 不保存退出
	:qa! 全部不保存退出

## Init

	"make vim save and load the folding of the document each time it loads"
	"also places the cursor in the last place that it was left."
	au BufWinLeave * mkview
	au BufWinEnter * silent loadview

### modeline 模式行
你可能只希望打开某一部分文件时，执行一些初始化．这样放到vimrc或者ftplugin中都不合适．这时，可以采用模式行——把初始化命令放到文件本身

比如你希望打开a.txt时，tab是7个，那么在a.txt前n行或者后n行中写入模式行（n=modelines）:

	/* vim:set tabstop=7: */

模式行的格式是(两边可放任意字符，建议是/* */)：

	any-text vim:set name=value ...: any-text

模式行的数量可以限制，比如：

	:set modelines=10

### 打开时光标位置
这个功能需要viminfo的支持(用vim --version | grep viminfo查看)

	'. "normal mode 返回上次离开时编辑的位置(见按保存状态移动)
	'" "normal mode 返回上次离开时光标所在的位置

	autocmd BufReadPost *
		 \ if line("'\"") <= line("$") |
		 \   exe "normal! g`\"" |
		 \ endif

## 缓冲与备份

### backup
make a backup before overwriting file

	:set backup
	:set backupext=.bak ＃备份文件的扩展名

	:w >>a.txt " 向文件中追加内容
	:sav a.txt :saveas a.txt(当前文件名也更改了)
	:.,$w file.txt #保存当前行到最后一行

### noswapfile

	:set noswapfile
	vim -x -n a.txt " 不缓存