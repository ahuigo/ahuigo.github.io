---
layout: page
title:	vim fold
category: blog
description: 
---
# Preface

# Folding Theory
Each of line has a fold level:

	echom foldlevel({lnum})

Example

	a           0
		b       1
		c       1
				'-1'(undefined)
			d   2
			e   2
		f       1
	g           0

## special level
'-1' is one of these special strings. So does "0".
Vim will interpret this as "the foldlevel of this line is equal to the foldlevel of the line above or below it, whichever is smaller"

'>level' treat as 'level': It tells Vim that the current line should open a fold of the given level.


# fold action

## move cursor by fold
[vim-fold](/p/vim-fold)

    zc "close one fold under current cursor
    zC "close all folds under current cursor

    zo "Open one fold under current cursor
    zO "Open all folds under current cursor
    {count}zo

	zR "open all fold
	zM "close all fold

	za " toggle one fold

    zj/zk "move to next/previous fold
    [z  "move to the begining of fold
    ]z  "move to the end of fold

## create marker fold

    :set fdm=marker
    "creat a fold
    zf{motion}
    {motion}zf
        "create a fold that match brackets.
        zf%

    "delete current fold
    zd

## fold ignore
by default Vim will ignore lines beginning with a # character when using indent folding

	setlocal foldignore=

# Fold Type

    :autocmd FileType vim setlocal foldmethod=marker
    :autocmd FileType vim setlocal fdm=marker

list folding:

    :h folding
        manual		manually define folds
        indent		more indent means a higher fold level
        expr		specify an expression to define folds
        syntax		folds defined by syntax highlighting
        diff		folds for unchanged text
        marker		folds defined by markers in the text

## manual
Create fold by hand and they are stored in RAM.

## marker
Vim folds your code based on characters in the actual text.

## diff
A special folding mode used when diff'ing files. We won't talk about this one at all because Vim automatically handles it.

## expr
This lets you use a custom piece of Vimscript to define where folds occur. It's the most powerful method, but also requires the most work. 

	setlocal foldmethod=expr
	setlocal foldexpr=GetPotionFold(v:lnum)

	function! GetPotionFold(lnum)
		return indent(a:lnum) / &shiftwidth
		return '0'
	endfunction

## indent
Vim uses your code's indentation to determine folds. Lines at the same indentation level fold together. (It suits Python especially)
