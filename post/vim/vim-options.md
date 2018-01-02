---
layout: page
title:	
category: blog
description: 
---
# Preface

# set options 

	:set {option}
	:se no{option} 
	:se {option}! toggle option
	:set {option}& "在后面加&时会重置option的默认值
	:se {option}? "show option
	:se "show all option
	:se viminfo-=s100

临时:

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
	
	
