---
layout: page
title:
category: blog
description:
---
# Preface
> http://learnvimscriptthehardway.stevelosh.com/chapters/45.html

# Syntax

## Syntax loading
> :h syn-loading

	:syntax enable

	#让vim知道xterm终端颜色（shell下）
	setenv TERM xterm-color 或者 TERM=xterm-color;export TERM

":syntax enable"(keep) and ":syntax on"(overrule) do the following:

    Source $VIMRUNTIME/syntax/syntax.vim
    |
    +-	Clear out any old syntax by sourcing $VIMRUNTIME/syntax/nosyntax.vim
    |
    +-	Source first syntax/synload.vim in 'runtimepath'
    |	|
    |	+-  Setup the colors for syntax highlighting.  If a color scheme is
    |	|   defined it is loaded again with ":colors {name}".  Otherwise
    |	|   ":runtime! syntax/syncolor.vim" is used.  ":syntax on" overrules
    |	|   existing colors, ":syntax enable" only sets groups that weren't
    |	|   set yet.
    |	|
    |	+-  Set up syntax autocmds to load the appropriate syntax file when
    |	|   the 'syntax' option is set. *synload-1*
    |	|
    |	+-  Source the user's optional file, from the |mysyntaxfile| variable.
    |	    This is for backwards compatibility with Vim 5.x only. *synload-2*
    |..........

	$VIMRUNTIME/syntax/
	$VIMRUNTIME/color/


## syntax keyword
Grammar:

	:help syn-keyword
	syntax keyword <group> <word1> <word2> ....

Example:

	syntax keyword potionKeyword loop times to while
	syntax keyword potionKeyword if elsif else
	syntax keyword potionKeyword class return
	syntax keyword potionFunction print join string

## syntax match
`:h syn-match`:

	:sy[ntax] match {group-name} [{options}] [excludenl] {pattern} [{options}]

Example：

	syn match potionComment "\v#.*$"
	highlight link potionComment Comment

groups defined later have priority over groups defined earlier:`help syn-priority.`

	syntax match potionOperator "\v-"
	syntax match potionOperator "\v-\="

## syntax region
`:h syn-region`:

	syntax region potionString start=/\v"/ skip=/\v\\./ end=/\v"/
	highlight link potionString String

# highlight

## hilight group

### list hilight group

	:hi "hilight list all color group
	:hi {group-name}
	:verbose hi Comment

### add hilight group

	:hi MyQuestions gui=bold term=bold cterm=bold
	:hi MyQuestions guifg=red guibg=green
	:hi Comment	ctermfg=Cyan guifg=#80a0ff

For gui:

	:highlight Normal guibg=Green guifg=Red

For terminal:

	:highlight Normal ctermfg=grey ctermbg=darkblue

> For more details, refer to ':h hi-normal-cterm' or ':h hi-normal'

#### hilight-args
`:h hilight-args`

	term	a normal terminal (vt100, xterm)
	cterm	a color terminal (MS-DOS console, color-xterm, these have the "Co"
		termcap entry)
	gui	the GUI

term:

	term={attr-list}			*attr-list* *highlight-term* *E418*
		attr-list is a comma separated list (without spaces) of the
			bold
			underline
			undercurl	not always available
			reverse
			inverse		same as reverse
			italic
			standout
			NONE		no attributes used (used to reset it)

## colorscheme
colorscheme is a vim file which include hilight commands

	:colorscheme :colo
		same as `:echo g:colors_name`, current colorscheme
	:colo {name}
		load color {name} from `colors/{name}.vim`

### get current color

	echo g:colors_name
	:colo

## highlight link

	:help :hi-link

To set a link:

    :hi[ghlight][!] [default] link {from-group} {to-group}

To remove a link:

    :hi[ghlight][!] [default] link {from-group} NONE

Example:

	highlight link potionKeyword Keyword
	highlight link potionFunction Function

## help

	:help iskeyword
	:help group-name
		to get an idea of some common highlighting groups that color scheme

# Syntax files
> :h syn-files

## autoload syntax file

The .vim files are normally loaded with an autocommand(filetype name).  For example:

	:au Syntax c	    runtime! syntax/c.vim
	:au Syntax cpp   runtime! syntax/cpp.vim

These commands are normally in the file $VIMRUNTIME/syntax/synload.vim.

	:set syntax=<filetype>

## Make Syntax file

2. Create a directory in there called "syntax".  For Unix:

	mkdir ~/.vim/syntax

3. Write the Vim syntax file.  Or download one from the internet.  Then write
   it in your syntax directory.  For example, for the "mine" syntax: >

	:w ~/.vim/syntax/mine.vim

Now you can start using your syntax file manually:

	:set syntax=mine

