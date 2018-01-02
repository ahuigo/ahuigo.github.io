---
layout: page
title:	
category: blog
description: 
---
# Preface

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

# vundle
pathogen本身不支持插件的白名单管理。而vundle比pathogen功能更丰富——插件白名单管理，插件的安装、更新、删除（再加上git submodule更方便）

## download vundle
先下载文件吧：

	git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

可以看到，是如下的结构

	.vim
	└── bundle
		└── vundle
			├── autoload
			│   ├── vundle
			│   │   ├── config.vim
			│   │   ├── installer.vim
			│   │   └── scripts.vim
			│   └── vundle.vim
			├── doc
			│   └── vundle.txt
			├── LICENSE-MIT.txt
			├── README.md
			└── test
				├── files
				│   └── test.erl
				├── minirc.vim
				└── vimrc

## config
按github给的config 写到.vimrc

	set nocompatible               " be iMproved
	filetype off                   " required!

	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc()

	" let Vundle manage Vundle
	" required! 
	Plugin 'vim-scripts/fcitx.vim'


	filetype plugin indent on     " required!

## :BundleInstall
执行:
	
	vim +PluginInstall +qall

再看看，自动下载了fcitx有木有？另外还对一个doc/生成了tags

	.vim
	└── bundle
	    ├── fcitx.vim
	    │   ├── plugin
	    │   │   ├── fcitx.py
	    │   │   └── fcitx.vim
	    │   ├── README
	    │   └── so
	    │       └── fcitx.vim
	    └── vundle
		├── autoload
		│   ├── vundle
		│   │   ├── config.vim
		│   │   ├── installer.vim
		│   │   └── scripts.vim
		│   └── vundle.vim
		├── doc
		│   ├── tags
		│   └── vundle.txt
		├── LICENSE-MIT.txt
		├── README.md
		└── test
		    ├── files
		    │   └── test.erl
		    ├── minirc.vim
		    └── vimrc

## 使用
使用:h vundle 查看详细帮助

	:h vundle

其中就提到：BundleInstall支持直接从github下载插件，你可以在配置文件中设置github插件路径（比如我的fcitx）。
或者，你也可以在命令行中下载，比如vim命令行安装我所使用的blog插件：
	
	:PluginInstall pkufranky/VimRepress

	:PluginList       - lists configured plugins
	:PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
	:PluginSearch foo - searches for foo; append `!` to refresh local cache
	:PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

安装完了后，还得在.vimrc中启用
	
	Plugin 'VimRepress'

[vundle]: https://github.com/VundleVim/Vundle.vim

# NeoBundle
A next generation of vundle
