---
layout: page
title:	
category: blog
description: 
---
# Preface


# Window 窗口

## powerline
这是一个增强状态栏的插件

### window title
	setl stl=about\ b.c

## scroll window
如果想两个窗口能同时滚动，则：

	:set scrollbind :set scb //默认

## create window 创建窗口

> 分割窗口时，新窗口会继承 local-options, `:h local-options`

### 分隔一个窗口

	:split [filename/dir] 开启一个新的窗口，并打开filename(默认是当前所编辑的文件)或者一个dir
	:3sp a.txt :3new a.txt #新窗口的高度为３行
	其它很多打开另一文件的命令都有一个变体——在前面加上一个s，就可以在新窗口打开此文件，eg:
	:stag 以新窗口打开，并跳到tag

### 垂直分割

	:3vsplit a.txt :3vsp a.txt #新窗口的宽度为３行
	:vnew #垂直打开一个新窗口，并开启一个新的缓冲区
	
	:vert new #其实任何命令前都可以用vertical

### 为每一个文件打开一个窗口

	vim -o a.txt b.txt #所有的窗口都水平排列
	vim -O a.txt b.txt #所有的窗口都垂直排列

### 分割窗口的位置

	:set splitbelow 新打开的窗口位于当前窗口的下方
	:set splitright 新打开的垂直窗口位于当前窗口的右方

分割窗口有一个修饰前缀：
	
	:leftabove {cmd} #新窗口位于当前窗口的左边或上边
		leftabove split file 上边
		leftabove vsplit file 左边
	:aboveleft {cmd} #新窗口位于左边或上边 同上一样

	:to :topleft {cmd} far left or far above

	:rightb :rightbelow {cmd} 
	:bel belowright {cmd} 


	:bo :botleft {cmd} #当前窗口的下边或右边

## close window 关闭和保存窗口

	:close :clo #与 :q不同的是，不会关闭最后一个窗口
	:only #关闭所有窗口，除了当前所编辑的窗口
	:qa :qall #quit all
	:qa! :qall #quit all (force)
		noremap <C-q> :qa!
	:wa :wall #write all
	:wqa #write & quit all

## window size 窗口大小

	ctrl+w + /:ctrl+w - 　#增加／减小当前窗口的高度
	[height]ctrl+w _	#指定当前窗口的高度
	:set winheight #期望最小高度
	:set winminheight #强制最小高度
	:set winwidth #期望最小宽度
	:set winminwidth #强制最小宽度

## switch window 切换窗口

	{n}ctrl+w w 	go to Nth window or next window
	{n}ctrl+6	 	go to Nth buffer or toggle last accessed buffer 
		ctrl+w ctrl+w 切换到下一个窗口
	ctrt+w h 切换到左边的窗口
	ctrl+w j 切换到下边
	ctrl+w k 切换到上边
	ctrl+w l 切换到右边
	ctrl+w t 切换到顶部窗口
	ctrl+w b 切换到底部窗口

	ctrl+6 当前窗口下切换到上一个编辑的文件
	ctrl+w ctrl+6 新建一个窗口下切换到上一个编辑的文件

### switch window cmd
> http://learnvimscriptthehardway.stevelosh.com/chapters/38.html

`ctrl+w` 可以用`:wincmd` 代替, nth window:

	:3wincmd w
	:3wincmd b

### Map window hotkeys:

	" map Ctrl-Tab to switch window
	nnoremap <C-tab> :EXbalt<CR>
	nnoremap <unique> <S-Up> <C-W><Up>
	nnoremap <unique> <S-Down> <C-W><Down>
	nnoremap <unique> <S-Left> <C-W><Left>
	nnoremap <unique> <S-Right> <C-W><Right>

## window number

	$ last window
	# last accessed window(<c-w>p will go)

### get window number

	"current window
	echo winnr()

	"last window number equal to window count
	let window_count = winnr('$')

	"last accessed window
	echo winnr('#')

## 窗口状态
	
	:set laststatus指定何时最近使用的窗口会有一个状态-显示当前编辑的filename
		0 永远没有
		1 只有分割窗口时
		2 所有
	:set showcmd "显示输入的命令
	:set ruler "显示行列
	<c-g> 显示当前编辑的文件信息

## move window 移动窗口
如果你对新分割窗口位置不满意，则可以移动

	ctrl+w H 移动到左边
	ctrl+w J 移动到下边
	ctrl+w K 移动到上边
	ctrl+w L 移动到右边

# buffer 缓冲区列表(buffer list)
[vim-window](/p/vim-window)

缓冲区列表：所有vim打开的文件
你可以用ls或者buffer 查看你打开了多少缓冲区。

	u	an unlisted buffer (only displayed when [!] is used) |unlisted-buffer| 
	%	the buffer in the current window(当前缓冲区)
		#	the alternate buffer for ":e #" (使用<C-^> 时 #缓冲区 会和 %缓冲区 相互切换)
			a	an active buffer: it is loaded and visible(激活缓冲区)
			h	a hidden buffer: It is loaded, but currently not displayed in a window |hidden-buffer| (隐藏缓冲区)
				-	a buffer with 'modifiable' off 
				=	a readonly buffer（只读缓冲区）
					+	a modified buffer(正修改的缓冲区)
					x   a buffer with read error
				
## bufwinnr
get window number of buf 1:

	echo bufwinnr(1)
	echo bufwinnr('vim-windo')

## switch buffer
缓冲区跳转常用的命令：

	:hide bn "hide current buffer, then jump to next buffer
	    map <C-H/L> :EXbp<CR> for exvim
	:bn :bnext
	:bp :bprevious
	:bf :bfirst
	:bl :blast

    "指定打开某缓冲区
	:b [count/file] :buffer [count/file] 
    {count}CTRL-6 {count}CTRL-^
    :e #[count]
	:sb [count/file] :sbuffer [count/file] #以新窗口指定打开某缓冲区

Edit the alternate file. Mostly the alternate file is the previous edited file. 

	"toggle buffer
    <C-6> or <C-^>
    "It is equal to 
    :e#
    :b#

## 删除缓冲区

	:bd [count/file] :bdelete [count/file] #删除缓冲区
	:2,5bd #删除缓冲区(从第2个到第5个)
	:bun [count/file] :bunload [count/file] #释放缓冲区（仅释放内存,不会改变缓冲区列表）

##	增加缓冲区 

	:file b.txt	"当前缓冲区指向文件b.txt 原来的缓冲区a.txt会成为: u# a.txt (必须使用:ls! 才能看到此缓冲区)
	:badd c.txt "添加一个缓冲区, 但不切换到此缓冲区
	:e c.txt "新添加一个当前激活缓冲区%a (:o c.txt 是一样的)
	:e! a.txt "强制打开新文件a.txt，会丢弃当对当前缓冲区的改动
	:hide e a.txt "打开a.txt,不会丢弃当前缓冲区改动

## 缓冲区窗口

	:ba "打开所有缓冲区窗口
	:tab ba "以tab打开所有缓冲区窗口
	:vert ba "以vert打开所有缓冲区窗口
	:new a.txt "为a.txt缓冲区单独开一个窗口(通常情况下:new :split 表现是一样的)
	:split a.txt  "或者用:sp a.txt
	:vert sp a.txt  "或者用垂直新窗口
    :vs# 重新打开上次关闭的缓冲区

## buftype

	:set buftype=nofile
	  <empty>	normal buffer
	  nofile	buffer which is not related to a file and will not be written
	  nowrite	buffer which will not be written
	  acwrite	buffer which will always be written with BufWriteCmd autocommands. 
	  quickfix	quickfix buffer, contains list of errors |:cwindow|
	  help		help buffer (you are not supposed to set this manually)

## get buffer name

	bufname("%")		name of current buffer

	bufname("#")		alternate buffer name
	bufname(0)		

	bufname(3)			name of buffer 3
	bufname("file2")	name of buffer where "file2" matches.

get buffer number:

	bufnr("file2")
	bufnr("#")

# Argument list(参数列表,Argument list)
又叫filelist(文件列表)
文件列表是一个特殊的文件集合(关闭时所有文件时会提醒你正在编辑多个文件), 这一集合属于缓冲区集合的子集（缓冲区包括所有打开的文件）

*Buffer*

- A buffer is a file loaded into memory for editing. It is identified using a name and a number.
- The buffer name is the name of the file associated with that buffer. It may not be unique.
- The buffer number is a unique sequential number assigned by vim.

*Args*  is a subset of buffer list.

- Args list is files opened at command line or open from the vim command line: `:args`

loop arglist

	:let n = 1
	:while n <= argc()	    " loop over all files in arglist
	:  exe "argument " . n
	:  let n = n + 1
	:endwhile

关闭一个文件可以通过buffer:

	:bd [count/file] :bdelete [count/file] #删除缓冲区

创建一个文件列表有两种方式：

	vim a.txt b.txt c.txt or vim *.txt
	:args a.txt b.txt c.txt or :args *.txt "定义一个文件列表

查看文件列表：

    "view args via :args without any arguments
	:args :ar

跳转:

	:n :next
	:prev :previous
	:fir :first
	:la :last
	:2n! :2next!
	:wn :wnext 或者 :write :next
	:wprev

标记跳转（不同的文件间标记跳转得使用大写标记）
	
	mF
	`F
	:marks

## tabpage 页签
如果打开窗口太多，屏幕就不够用的，此时就应该使用页签了
很多命令前都可以加tab

### 打开页签	

	:tabe a.txt #以新页签打开a.txt
	:tab split a.txt #以新页签打开a.txt (在命令前加tab)

### 查看页签

	:tabs 

### 跳页签

	gt "goto next tab
	5gt "goto 5th tab
	5gT "goto 5th prev tab
	:tabl :tablast
	:tabr :tabrewind "first
	:tabn :tabnext 

### tips

	" for macvim
	if has("gui_running")
		set go=aAce  " remove toolbar
		"set transparency=30
		set guifont=Monaco:h13
		set showtabline=2
		set columns=140
		set lines=40
		noremap <D-M-Left> :tabprevious<cr>
		noremap <D-M-Right> :tabnext<cr>
		map <D-1> 1gt
		map <D-2> 2gt
		map <D-3> 3gt
		map <D-4> 4gt
		map <D-5> 5gt
		map <D-6> 6gt
		map <D-7> 7gt
		map <D-8> 8gt
		map <D-9> 9gt
		map <D-0> :tablast<CR>
	endif	
