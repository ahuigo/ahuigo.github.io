---
layout: page
title: vim-help
category: blog
description: 
date: 2018-10-04
---
# help 帮助
> Refer to : http://vim.wikia.com/wiki/Learn_to_use_help

之所以我把help放在这里，是因为help实在是太重要了。关于d这个操作，大家一般是在normal mode下用来删除. 其实在:命令下也有:d。
关于俩者的区别，就可以直接help 查看到其用法。

	:h d
	:h :d

不同模式下命令的help 用法:

	:h CTRL-L　"normal mode
	:h g_CTRL-G "normal mode
	:h c_CTRL-L "ex mode
	:h CTRL-q "normal mode
	:h i_CTRL-R "insert mode

vim中的很多命令都可以结合使用，比如强大的`:g`, 我们先help 看看他的用法。

	:h :g

查看完用法后，我们就知道怎么用了。如果我想删除所有的空行，怎么做呢？可以用:g 匹配出所有的空行，再用`:d` 删除

	:g/^\s*$/d

## help set

    :h set
    :h 'smartcase'
    :h 'ignorecase'

## help completion

	:h {pat}

Press `Ctrl-d` to list all mathed pattern. Then press `Tab` to select

## help links

	Enter :h to open the main help page.
	Type /quick to search for "quick" (should find the quickref link).
	Press `Ctrl-]` to follow the link (jump to the quickref topic).
	After browsing the quickref topic, press `Ctrl-T` to go back to the previous topic.
	You can also press `Ctrl-O` to jump to *older locations*, or `Ctrl-I` to jump to newer locations.

## context
Each help topic has a context:

	Prefix	Example	Context
	:	:h :r	ex command (command starting with a colon)
	none	:h r	normal mode
	v_	:h v_r	visual mode
	i_	:h i_CTRL-W	insert mode
	c_	:h c_CTRL-R	ex command line
	/	:h /\r	search pattern (in this case, :h \r also works)
	'	:h 'ro'	option
	-	:h -r	Vim argument (starting Vim)

## helpgrep
Search all the help files with the :helpgrep command, for example:

	:helpgrep \csearch.\{,12}file

`\c` means the pattern is case insensitive.
The pattern finds "search" then up to 12 characters followed by "file".

Then open quickfix:

	:cc

## simplify help navigation
The following mappings simplify navigation when viewing help:

	Press Enter to jump to the subject (topic) under the cursor.
	Press Backspace to return from the last jump.
	Press s to find the next subject, or S to find the previous subject.
	Press o to find the next option, or O to find the previous option.

Create file `~/.vim/ftplugin/help.vim` (Unix) or `$HOME/vimfiles/ftplugin/help.vim` (Windows) containing:

	nnoremap <buffer> <CR> <C-]>
	nnoremap <buffer> <BS> <C-T>
	nnoremap <buffer> o /'\l\{2,\}'<CR>
	nnoremap <buffer> O ?'\l\{2,\}'<CR>
	nnoremap <buffer> s /\|\zs\S\+\ze\|<CR>
	nnoremap <buffer> S ?\|\zs\S\+\ze\|<CR>

The following mappings (which can go in your vimrc) simplify navigating the results of quickfix commands such as (among others) :helpgrep

	:nnoremap <S-F1>  :cc<CR>
	:nnoremap <F2>    :cnext<CR>
	:nnoremap <S-F2>  :cprev<CR>
	:nnoremap <F3>    :cnfile<CR>
	:nnoremap <S-F3>  :cpfile<CR>
	:nnoremap <F4>    :cfirst<CR>
	:nnoremap <S-F4>  :clast<CR>

## 文档(doc)

	.vim/doc
	:helptags ~/.vim/doc #重建tags

##　K(man)
在一个单词上按K，可查看其man(ual).比如在ls上按K.等同于：

	:!man ls

如果想获得macvim 的menu 帮助

	:h macvim-menu

# help-write
> :help help-writing

`figlet -f ogre "Potion`命令来得到这些有趣的字符的. Figlet is a shell tool(`brew install figlet`)

vim 的很多插件都有vim 文档说明，这些文档说明是怎么编写的呢？查看这里

help doc example: http://learnvimscriptthehardway.stevelosh.com/chapters/54.html

文档示例:

	*potion.txt* functionality for the potion programming language

						  ___      _   _              ~
						 / _ \___ | |_(_) ___  _ __   ~
						/ /_)/ _ \| __| |/ _ \| '_ \  ~
					   / ___/ (_) | |_| | (_) | | | | ~
					   \/    \___/ \__|_|\___/|_| |_| ~

			  Functionality for the Potion programming language.
			Includes syntax highlighting, code folding, and more!
	====================================================================
	CONTENTS                                            *PotionContents*

		1. Usage ................ |PotionUsage|
		2. Mappings ............. |PotionMappings|
		3. License .............. |PotionLicense|
		4. Bugs ................. |PotionBugs|
		5. Contributing ......... |PotionContributing|
		6. Changelog ............ |PotionChangelog|
		7. Credits .............. |PotionCredits|
	====================================================================
	Section 1: Usage                                       *PotionUsage*

	This plugin with automatically provide syntax highlighting for
	Potion files (files ending in .pn).

	It also...