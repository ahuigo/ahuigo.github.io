---
layout: page
title: vim-plugin
category: blog
description: 
date: 2018-10-04
---
# Preface
list all plugins

    " where was an option set  
    :scriptnames            : list all plugins, _vimrcs loaded (super)  
    :verbose set history?   : reveals value of history and where set  
    :function               : list functions  
    :func SearchCompl       : List particular function

# Plugin Layout

## Basic Layout

:set runtimepath=~/.vim

	~/.vim/filetype.vim
		set filetype
	~/.vim/colors/
		all files inside are treated as color schemes
		:color mycolor ,will look for ~/.vim/colors/mycolor.vim and run it
	~/.vim/plugin/
		Files inside will each be run once *every time* vim starts.
	~/.vim/ftdetect/
		will be run every time.
		Only set up autocommand that detect and set the `filetype` type.
		But required with `/ftdetect/{filetype}.vim` only
	~/.vim/syntax/
		will be run every time.
		But required with `/syntax/{filetype}.vim` only
	~/.vim/ftplugin/
		When vim set buffer's type to a value(eg. derp), it then look for a file in `ftplugin` that matches
		(eg. ftplugin/derp.vim or ftplugin/derp/*.vim).
	~/.vim/indent/
		like ftplugin files. They get loaded based on their filetype
		Indet files should relate to indent options and these option should be buffer-local
	~/.vim/compiler/
		They should set compiler-related options in the current buffer based on their names.
	~/.vim/after/
		be loaded every time Vim starts, but after the files in ~/.vim/plugin/.
	~/.vim/autoload/
		autoload is a way to delay the loading of your plugin's code until it's actually needed. 
	~/.vim/doc/
		Finally, the ~/.vim/doc/ directory is where you can add documentation for your plugin.

# Pathogen

## runtimepath
The Pathogen plugin automatically adds paths to your runtimepath when you load Vim. Any directories inside `~/.vim/bundle/` will each be added to the runtimepath.

	:set runtimepath+=~/.vim/bundle/{name}

`:color mycolor` 就会在`runtimepath` 中查找`colors/mycolor.vim`:

	:color mycolor