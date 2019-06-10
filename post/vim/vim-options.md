---
layout: page
title: vim-options
category: blog
description: 
date: 2018-10-04
---
# Set options 
set 命令的语法

	:set {option}
	:se no{option} 
	:se {option}! "toggle option
	:set {option}& "在后面加&时会重置option的默认值
	:se {option}? "show option
	:se "show all option
	:se viminfo-=s100

临时set 命令（当前文件下生效）:

	:setlocal nowrap

## default options
`:h &vim`

	:se[t] {option}&        Reset option to its default value.  May depend on the
							current value of 'compatible'. {not in Vi}
	:se[t] {option}&vi      Reset option to its Vi default value. {not in Vi}
	:se[t] {option}&vim     Reset option to its Vim default value. {not in Vi}

	:se[t] all&             Reset all options

## help options

	:help 'number' (notice the quotes).
	:help relativenumber.
	:help numberwidth.
	:help wrap.
	:help shiftround.
	:help matchtime.

# ts & sw 区别
与缩进有关的是ts/sw 选项，我的配置一般默认：

    :set ts=4 sw=4

ts & sw 的区别是:
1. sw(shiftwidth) 是控制缩进步长的, 会影响到`<<` 和`>>` 这两个是缩进命令
1. ts(tabstop) 是指`tab`符的占用的字符长度, 比如`set ts=16`
   1. 在vim 中
      1. 如果开启了`expandtab`, 那么`tab` 会被替换成`ts=16` 个`空格符`, 
      1. 如果没开启`expandtab`, 那么`tab`符就是占用`ts=16` 个字符的宽度的`tab`符
   2. 在neovim 中有点复杂：
      1. 如果在`非空白符`后输入`tab`, 那么每次移位`4`个空格字符长度
      1. 否则，输入`tab`, 那么每次移位是`sw(shiftwidth)`个空格字符长度
      3. 移位的字符宽度达到`ts=16`个字符宽度后, 就将空格字符 替换成`tab`字符（仅当设置`:set noexpandtab`）

# statusline

	:set statusline=%f\ -\ FileType:\ %y
	:set statusline=%f         " Path to the file
	:set statusline+=\ -\      " Separator
	:set statusline+=FileType: " Label
	:set statusline+=%y        " Filetype of the file

path:

	:set statusline=%F		"full path
	:set statusline=%.20F	"display only last 20 characters

line format:

	:set statusline=%l    " Current line
	:set statusline+=/    " Separator
	:set statusline+=%L   " Total lines

## width and padding
general format

	%-0{minwid}.{maxwid}{item}

with width and padding

	:set statusline=Current:\ %4l\ Total:\ %4L

	" padding on the right
	:set statusline=[%-4l]	"[12  ]

with zero left:

	:set statusline=[%04l] "[0012]

## splitting
`%=` to splitting:

	:set statusline=%f         " Path to the file
	:set statusline+=%=        " Switch to the right side
	:set statusline+=%l        " Current line
	:set statusline+=/         " Separator
	:set statusline+=%L        " Total line